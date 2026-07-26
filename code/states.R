#!/usr/bin/env Rscript
# States + territories (geoid, stusps, name + geometry), straight from the
# Census cartographic boundary file. The 500k series is the one series
# that carries all 50 states + DC + PR + the island territories, at the
# finest published resolution.

source("code/utils.R")

states_sf <-
  read_cb("cb_2024_us_state_500k", 2024) |>
  transmute(geoid = GEOID, stusps = STUSPS, name = NAME) |>
  st_transform(4326) |>
  arrange(geoid)

sfarrow::st_write_parquet(states_sf, "data/states-sf.parquet")
