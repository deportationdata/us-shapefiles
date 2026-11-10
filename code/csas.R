#!/usr/bin/env Rscript
# Combined Statistical Areas (groups of adjacent CBSAs with commuting ties)
# from the geo_vintage CB file.

source("code/utils.R")

csas_sf <-
  tigris::combined_statistical_areas(
    cb = TRUE,
    resolution = "500k",
    year = geo_vintage
  ) |>
  transmute(geoid = GEOID, name = NAME, namelsad = NAMELSAD) |>
  st_transform(4326) |>
  arrange(geoid)

stopifnot(
  !anyNA(csas_sf$geoid),
  !anyDuplicated(csas_sf$geoid),
  !any(st_is_empty(csas_sf)),
  st_crs(csas_sf) == st_crs(4326)
)

sf::st_write(
  csas_sf,
  dsn = "data/csas-sf.parquet",
  driver = "Parquet",
  layer_options = "USE_PARQUET_GEO_TYPES=ONLY",
  delete_dsn = file.exists("data/csas-sf.parquet"),
  quiet = TRUE
)
