#!/usr/bin/env Rscript
# The CBSAs, except that the 13 metros the Census splits into Metropolitan
# Divisions appear as those divisions (lsad M3) instead of as one CBSA.
# Every CBSA is covered once, by itself or by its divisions; cbsa_geoid
# says which CBSA a row belongs to. tigris has no function for the division
# file, so it is downloaded directly.

source("code/utils.R")

divisions_sf <-
  read_sf(glue(
    "/vsizip//vsicurl/https://www2.census.gov/geo/tiger/GENZ{geo_vintage}/",
    "shp/cb_{geo_vintage}_us_metdiv_500k.zip"
  )) |>
  transmute(
    geoid = GEOID,
    name = NAME,
    namelsad = NAMELSAD,
    lsad = LSAD,
    cbsa_geoid = CBSAFP
  ) |>
  st_transform(4326)

metro_divisions_sf <-
  st_read("data/cbsas-sf.parquet", quiet = TRUE) |>
  filter(!geoid %in% divisions_sf$cbsa_geoid) |>
  transmute(geoid, name, namelsad, lsad, cbsa_geoid = geoid) |>
  bind_rows(divisions_sf) |>
  arrange(geoid)

stopifnot(
  !anyNA(metro_divisions_sf$geoid),
  !anyDuplicated(metro_divisions_sf$geoid),
  !any(st_is_empty(metro_divisions_sf)),
  st_crs(metro_divisions_sf) == st_crs(4326)
)

sf::st_write(
  metro_divisions_sf,
  dsn = "data/metro-divisions-sf.parquet",
  driver = "Parquet",
  layer_options = "USE_PARQUET_GEO_TYPES=ONLY",
  delete_dsn = file.exists("data/metro-divisions-sf.parquet"),
  quiet = TRUE
)
