#!/usr/bin/env Rscript
# Core Based Statistical Areas — metropolitan (lsad M1) and micropolitan (M2)
# statistical areas — from the geo_vintage CB file. csa_geoid is the Combined
# Statistical Area the CBSA belongs to, NA for most.

source("code/utils.R")

cbsas_sf <-
  tigris::core_based_statistical_areas(
    cb = TRUE,
    resolution = "500k",
    year = geo_vintage
  ) |>
  transmute(
    geoid = GEOID,
    name = NAME,
    namelsad = NAMELSAD,
    lsad = LSAD,
    csa_geoid = na_if(CSAFP, "")
  ) |>
  st_transform(4326) |>
  arrange(geoid)

stopifnot(
  !anyNA(cbsas_sf$geoid),
  !anyDuplicated(cbsas_sf$geoid),
  !any(st_is_empty(cbsas_sf)),
  st_crs(cbsas_sf) == st_crs(4326)
)

sf::st_write(
  cbsas_sf,
  dsn = "data/cbsas-sf.parquet",
  driver = "Parquet",
  layer_options = "USE_PARQUET_GEO_TYPES=ONLY",
  delete_dsn = file.exists("data/cbsas-sf.parquet"),
  quiet = TRUE
)
