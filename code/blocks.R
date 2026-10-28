#!/usr/bin/env Rscript
# Every 2020 Census block with POP20 and its geo_vintage county, place, county
# subdivision and ZCTA, from TIGER/Line TABBLOCK20 and FACES. The FIPS lists
# come from data/states-sf.parquet and counties-sf.parquet: build those first.

source("code/utils.R")
library(mirai)
library(tidyr)

# Downloads are kept here and reused.
cache <- path.expand(file.path(
  rappdirs::user_cache_dir("tigris"),
  "us-shapefiles"
))

# Workers for map(in_parallel()); they need the same packages attached.
daemons(max(1L, parallel::detectCores() %/% 2L))
everywhere(source("code/utils.R"))

# ---- download helpers -------------------------------------------------------
# an error page or truncated download saved as .zip does not list
zip_ok <- function(f) {
  file.exists(f) && !is.null(possibly(unzip)(f, list = TRUE))
}

# Fetch every url into dir, skipping intact files, with retries. The Census
# firewall rejects a few bare URLs with an HTML page but passes the same URL
# with a query string, so retries append one.
fetch_all <- function(urls, dir, tries = 4) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  dest <- file.path(dir, basename(urls))
  for (i in seq_len(tries)) {
    todo <- !map_lgl(dest, zip_ok)
    if (!any(todo)) {
      break
    }
    if (i > 1) {
      Sys.sleep(10 * (i - 1))
    }
    unlink(dest[todo])
    message(glue("fetching {sum(todo)} files into {dir} (attempt {i})"))
    src <- if (i == 1) urls[todo] else str_c(urls[todo], "?attempt=", i)
    curl::multi_download(
      src,
      dest[todo],
      resume = FALSE,
      multiplex = TRUE,
      progress = interactive()
    )
  }
  stopifnot("downloads still missing or broken" = every(dest, zip_ok))
  dest
}

# ---- 2020 blocks: population, housing, interior point, land area -------------
state_fips <-
  st_read("data/states-sf.parquet", quiet = TRUE) |>
  st_drop_geometry() |>
  pull(geoid) |>
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
  all(str_length(blocks$geoid) == 15),
  # 50 states + DC + PR, 2020 Census
  sum(blocks$pop20, na.rm = TRUE) == 334735155
)

# ---- FACES: block → current county / place / county subdivision, block → 2020 ZCTA ---------
county_fips <-
  st_read("data/counties-sf.parquet", quiet = TRUE) |>
  st_drop_geometry() |>
  pull(geoid) |>
  sort()

faces <-
  glue(
    "https://www2.census.gov/geo/tiger/TIGER{geo_vintage}/FACES/tl_{geo_vintage}_{county_fips}_faces.zip"
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
          county_subdivision_geoid = str_c(STATEFP, COUNTYFP, COUSUBFP),
          zcta = ZCTA5CE20,
          area = as.numeric(ATOTAL)
        )
    }),
    .progress = TRUE
  ) |>
  list_rbind()

# One row per block, geography and code its faces touch. A block split by an
# annexation goes whole to its largest-area side, ties to the lowest code, NA
# (none) last; stacking the four geographies decides this once.
sides <-
  faces |>
  pivot_longer(
    c(county_geoid, place_geoid, county_subdivision_geoid, zcta),
    names_to = "geography",
    values_to = "code"
  ) |>
  summarise(area = sum(area), .by = c(geoid, geography, code)) |>
  arrange(geoid, geography, desc(area), code)

# Blocks whose faces fall in more than one place (or partly in none).
place_split <-
  sides |>
  filter(geography == "place_geoid") |>
  summarise(place_split = n() > 1, .by = geoid)

blocks_xwalk <-
  sides |>
  slice_head(n = 1, by = c(geoid, geography)) |>
  pivot_wider(id_cols = geoid, names_from = geography, values_from = code) |>
  inner_join(blocks, by = "geoid") |>
  left_join(place_split, by = "geoid") |>
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
    county_subdivision_geoid,
    place_split
  ) |>
  arrange(geoid)

stopifnot(
  # the FACES and TABBLOCK20 block universes are the same 8,180,866 blocks
  nrow(blocks_xwalk) == nrow(blocks),
  nrow(blocks_xwalk) == n_distinct(faces$geoid),
  !anyDuplicated(blocks_xwalk$geoid),
  all(blocks_xwalk$county_geoid %in% county_fips),
  # every block has a place side in sides, so the place_split join leaves no NA
  !anyNA(blocks_xwalk$place_split),
  # 2020 ZCTAs are fixed for the decade
  between(n_distinct(na.omit(blocks_xwalk$zcta)), 33000, 34000)
)

arrow::write_parquet(
  blocks_xwalk,
  "data/blocks-xwalk.parquet",
  compression = "zstd"
)

daemons(0)
