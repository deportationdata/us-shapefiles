#!/usr/bin/env Rscript
# County subdivisions (towns, townships, CCDs, barrios) from the geo_vintage CB
# file; tigris has no national subdivision file, so one download per state.

source("code/utils.R")

county_subdivisions_sf <-
  map(
    state_codes,
    tigris::county_subdivisions,
    cb = TRUE,
    year = geo_vintage
  ) |>
  bind_rows() |>
  transmute(
    geoid = GEOID,
    stusps = STUSPS,
    name = NAME,
    namelsad = NAMELSAD,
    lsad = LSAD,
    county_geoid = str_sub(GEOID, 1, 5),
    aland = ALAND,
    geometry
  ) |>
  st_transform(4326) |>
  arrange(geoid)

# FUNCSTAT and CLASSFP are in the TIGER/Line file, not the CB file
county_subdivision_codes <-
  map(
    state_codes,
    \(s) {
      tigris::county_subdivisions(s, cb = FALSE, year = geo_vintage) |>
        st_drop_geometry() |>
        select(geoid = GEOID, funcstat = FUNCSTAT, classfp = CLASSFP)
    }
  ) |>
  bind_rows()

county_subdivisions_sf <-
  county_subdivisions_sf |>
  left_join(county_subdivision_codes, by = "geoid") |>
  relocate(funcstat, classfp, .after = lsad)

stopifnot(
  !anyNA(county_subdivisions_sf$funcstat),
  !anyNA(county_subdivisions_sf$classfp),
  !anyNA(county_subdivisions_sf$geoid),
  !anyDuplicated(county_subdivisions_sf$geoid),
  !any(st_is_empty(county_subdivisions_sf)),
  st_crs(county_subdivisions_sf) == st_crs(4326)
)
stopifnot(all(state_codes %in% unique(county_subdivisions_sf$stusps)))

sf::st_write(
  county_subdivisions_sf,
  dsn = "data/county-subdivisions-sf.parquet",
  driver = "Parquet",
  layer_options = "USE_PARQUET_GEO_TYPES=ONLY",
  delete_dsn = file.exists("data/county-subdivisions-sf.parquet"),
  quiet = TRUE
)
