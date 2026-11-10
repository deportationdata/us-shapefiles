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

stopifnot(
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
