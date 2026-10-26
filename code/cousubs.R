#!/usr/bin/env Rscript

source("code/utils.R")

state_codes <- c(state.abb, "DC", "PR", "GU", "VI", "MP", "AS")

cousubs_sf <-
  map(state_codes, \(s) {
    tigris::county_subdivisions(state = s, cb = TRUE, year = GEO_VINTAGE)
  }) |>
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

stopifnot(!anyDuplicated(cousubs_sf$geoid))
stopifnot(all(state_codes %in% unique(cousubs_sf$stusps)))

sf::st_write(
  cousubs_sf,
  dsn = "data/cousubs-sf.parquet",
  driver = "Parquet",
  layer_options = "USE_PARQUET_GEO_TYPES=ONLY",
  delete_dsn = file.exists("data/cousubs-sf.parquet"),
  quiet = TRUE
)
