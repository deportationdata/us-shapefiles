#!/usr/bin/env Rscript
# Dissolved from states (the Census nation file is only published at 5m/20m).

source("code/utils.R")

nationwide_sf <-
  st_read("data/states-sf.parquet", quiet = TRUE) |>
  summarize(geoid = "US", name = "United States")

sf::st_write(
  nationwide_sf,
  dsn = "data/nationwide-sf.parquet",
  driver = "Parquet",
  layer_options = "USE_PARQUET_GEO_TYPES=ONLY",
  delete_dsn = file.exists("data/nationwide-sf.parquet"),
  quiet = TRUE
)
