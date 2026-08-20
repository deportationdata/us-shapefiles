#!/usr/bin/env Rscript
# Nation (geoid, name + geometry): every state + territory in
# data/states-sf.parquet dissolved into one feature, so the national
# outline matches the states file exactly. (The Census CB nation file is
# published only at 5m/20m — coarser than the 500k the other levels use.)
# Run after code/states.R.

source("code/utils.R")

nationwide_sf <-
  st_read_parquet("data/states-sf.parquet") |>
  summarize(geoid = "US", name = "United States")

st_write_parquet(nationwide_sf, "data/nationwide-sf.parquet")
