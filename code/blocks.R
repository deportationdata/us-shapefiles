#!/usr/bin/env Rscript
# Every 2020 Census block with POP20 and its GEO_VINTAGE county, place, cousub
# and ZCTA, from TIGER/Line TABBLOCK20 and FACES: data/blocks-xwalk.parquet.

source("code/utils.R")
library(mirai)
library(tidyr)

# Downloads are kept here and reused (override with US_SHAPEFILES_CACHE).
cache <- path.expand(Sys.getenv(
  "US_SHAPEFILES_CACHE",
  file.path(rappdirs::user_cache_dir("tigris"), "us-shapefiles")
))

# Workers for map(in_parallel()); they need the same packages attached.
daemons(max(1L, parallel::detectCores() %/% 2L))
everywhere(source("code/utils.R"))

# ---- download helpers -------------------------------------------------------
# An HTTP error page saved under a .zip name, or a truncated download, does not list.
zip_ok <- function(f) {
  file.exists(f) && !is.null(possibly(unzip)(f, list = TRUE))
}

# Fetch every url into dir (skipping intact files), retrying; returns the paths.
# The Census firewall rejects a few bare URLs (e.g. TIGER2025 FACES 22113) with
# an HTML "Request Rejected" page; the same URL with a query string goes through,
# so retries append one.
fetch_all <- function(urls, dir, tries = 4) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  dest <- file.path(dir, basename(urls))
  for (i in seq_len(tries)) {
    todo <- !map_lgl(dest, zip_ok)
    if (!any(todo)) {
      break
    }
    unlink(dest[todo])
    message(glue("fetching {sum(todo)} files into {dir} (attempt {i})"))
    src <- if (i == 1) urls[todo] else paste0(urls[todo], "?attempt=", i)
    curl::multi_download(
      src,
      dest[todo],
      resume = FALSE,
      multiplex = TRUE,
      progress = interactive()
    )
    if (i < tries) Sys.sleep(10 * i)
  }
  stopifnot("downloads still missing or broken" = every(dest, zip_ok))
  dest
}

# ---- 2020 blocks: population, housing, interior point, land area -------------
state_fips <-
  tigris::states(cb = TRUE, resolution = "500k", year = GEO_VINTAGE) |>
  st_drop_geometry() |>
  pull(GEOID) |>
  sort()

blocks <-
  glue(
    "https://www2.census.gov/geo/tiger/TIGER2020/TABBLOCK20/tl_2020_{state_fips}_tabblock20.zip"
  ) |>
  fetch_all(file.path(cache, "tabblock20")) |>
  map(
    in_parallel(\(z) {
      layer <- tools::file_path_sans_ext(basename(z))
      read_sf(
        glue("/vsizip/{z}"),
        # to save time
        query = glue(
          "SELECT GEOID20, POP20, HOUSING20, INTPTLAT20, INTPTLON20, ALAND20 FROM {layer}"
        )
      ) |>
        transmute(
          geoid = GEOID20,
          pop20 = as.integer(POP20),
          housing20 = as.integer(HOUSING20),
          lat = as.numeric(INTPTLAT20),
          lon = as.numeric(INTPTLON20),
          aland = as.numeric(ALAND20)
        )
    }),
    .progress = TRUE
  ) |>
  list_rbind()

# AS/GU/MP/VI blocks carry no POP20, so pop20 is NA there.
stopifnot(
  !anyDuplicated(blocks$geoid),
  all(nchar(blocks$geoid) == 15),
  # 50 states + DC + PR, 2020 Census
  sum(blocks$pop20, na.rm = TRUE) == 334735155
)

# ---- FACES: block → current county / place / cousub, block → 2020 ZCTA ---------
county_fips <-
  tigris::counties(cb = TRUE, resolution = "500k", year = GEO_VINTAGE) |>
  st_drop_geometry() |>
  pull(GEOID) |>
  sort()

faces <-
  glue(
    "https://www2.census.gov/geo/tiger/TIGER{GEO_VINTAGE}/FACES/tl_{GEO_VINTAGE}_{county_fips}_faces.zip"
  ) |>
  fetch_all(file.path(cache, "faces")) |>
  map(
    in_parallel(\(z) {
      read_sf(glue("/vsizip/{z}")) |>
        st_drop_geometry() |>
        mutate(across(c(PLACEFP, COUSUBFP, ZCTA5CE20), \(x) na_if(x, ""))) |>
        # str_c propagates NA: a face outside any place gets no place_geoid
        transmute(
          geoid = str_c(STATEFP20, COUNTYFP20, TRACTCE20, BLOCKCE20),
          # current-vintage state: a block can change state (river boundaries)
          county_geoid = str_c(STATEFP, COUNTYFP),
          place_geoid = str_c(STATEFP, PLACEFP),
          cousub_geoid = str_c(STATEFP, COUNTYFP, COUSUBFP),
          zcta = ZCTA5CE20,
          area = as.numeric(ATOTAL)
        )
    }),
    .progress = TRUE
  ) |>
  list_rbind()

# A block split by an annexation goes whole to its largest-area side;
# ties to the lowest code, NA (none) last. Stack the four geographies so
# this is decided once, for every block x geography pair.
sides <-
  faces |>
  pivot_longer(
    c(county_geoid, place_geoid, cousub_geoid, zcta),
    names_to = "geography",
    values_to = "code"
  ) |>
  summarise(area = sum(area), .by = c(geoid, geography, code)) |>
  arrange(geoid, geography, desc(area), code)

# Blocks whose faces fall in more than one place (or partly in none).
split_places <-
  sides |>
  filter(geography == "place_geoid") |>
  count(geoid) |>
  filter(n > 1) |>
  pull(geoid)

blocks_xwalk <-
  sides |>
  slice_head(n = 1, by = c(geoid, geography)) |>
  pivot_wider(id_cols = geoid, names_from = geography, values_from = code) |>
  inner_join(blocks, by = "geoid") |>
  mutate(place_split = geoid %in% split_places) |>
  select(
    geoid,
    pop20,
    housing20,
    lat,
    lon,
    aland,
    zcta,
    county_geoid,
    place_geoid,
    cousub_geoid,
    place_split
  ) |>
  arrange(geoid)

stopifnot(
  # the FACES and TABBLOCK20 block universes are the same 8,180,866 blocks
  nrow(blocks_xwalk) == nrow(blocks),
  nrow(blocks_xwalk) == n_distinct(faces$geoid),
  !anyDuplicated(blocks_xwalk$geoid),
  all(blocks_xwalk$county_geoid %in% county_fips),
  # 2020 ZCTAs are fixed for the decade
  between(n_distinct(na.omit(blocks_xwalk$zcta)), 33000, 34000)
)

arrow::write_parquet(
  blocks_xwalk,
  "data/blocks-xwalk.parquet",
  compression = "zstd"
)

daemons(0)
