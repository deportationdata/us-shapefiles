#!/usr/bin/env Rscript

source("code/utils.R")

states_sf <-
  tigris::states(cb = TRUE, resolution = "500k", year = 2024) |>
  transmute(geoid = GEOID, stusps = STUSPS, name = NAME) |>
  st_transform(4326) |>
  arrange(geoid)

sf::st_write(states_sf, dsn = "data/states-sf.parquet", driver = "Parquet", layer_options = "USE_PARQUET_GEO_TYPES=ONLY", delete_dsn = file.exists("data/states-sf.parquet"), quiet = TRUE)
