#!/usr/bin/env Rscript
# Each 2020 ZCTA → the county and place holding most of its 2020 population
# (land area in the island territories), from data/blocks-xwalk.parquet; names
# from data/counties-sf.parquet and data/places-sf.parquet, so run those first.

source("code/utils.R")
library(tidyr)

counties <-
  st_read("data/counties-sf.parquet", quiet = TRUE) |>
  st_drop_geometry() |>
  transmute(county_geoid = geoid, stusps, county = name)

places <-
  st_read("data/places-sf.parquet", quiet = TRUE) |>
  st_drop_geometry() |>
  transmute(place_geoid = geoid, place = name)

# Weight is 2020 population; a ZCTA with none (the territories' blocks carry no
# POP20) is weighted by land area instead.
blocks <-
  arrow::read_parquet("data/blocks-xwalk.parquet") |>
  filter(!is.na(zcta)) |>
  mutate(by_pop = sum(pop20, na.rm = TRUE) > 0, .by = zcta) |>
  mutate(weight = if_else(by_pop, coalesce(as.numeric(pop20), 0), aland))

# Largest share of the ZCTA's weight per geography, ties to the lowest code,
# decided once on the stack. Blocks in no place compete as one sentinel code
# per state; on land-area ZCTAs only real places compete, or open land wins.
zip_xwalk <-
  blocks |>
  mutate(
    place_key = coalesce(place_geoid, str_c(str_sub(county_geoid, 1, 2), "99999"))
  ) |>
  pivot_longer(c(county_geoid, place_key), names_to = "geography", values_to = "code") |>
  # the county always competes; the no-place code only where weight is population
  filter(geography == "county_geoid" | by_pop | !is.na(place_geoid)) |>
  summarise(weight = sum(weight), .by = c(zcta, geography, code)) |>
  arrange(zcta, geography, desc(weight), code) |>
  slice_head(n = 1, by = c(zcta, geography)) |>
  pivot_wider(id_cols = zcta, names_from = geography, values_from = code) |>
  mutate(place_geoid = if_else(str_ends(place_key, "99999"), NA_character_, place_key)) |>
  left_join(counties, by = "county_geoid") |>
  left_join(places, by = "place_geoid") |>
  transmute(zcta, stusps, county, county_geoid, place, place_geoid) |>
  arrange(zcta)

stopifnot(
  !anyDuplicated(zip_xwalk$zcta),
  all(str_detect(zip_xwalk$zcta, "^\\d{5}$")),
  all(!is.na(zip_xwalk$stusps)),
  all(!is.na(zip_xwalk$county)),
  "a winning place_geoid is missing from the CB places file" =
    all(!is.na(zip_xwalk$place) | is.na(zip_xwalk$place_geoid)),
  "zip_xwalk names contain non-UTF-8 bytes or U+FFFD" =
    all(validUTF8(zip_xwalk$county)) &&
      !any(str_detect(zip_xwalk$county, "�")) &&
      all(validUTF8(na.omit(zip_xwalk$place))) &&
      !any(str_detect(na.omit(zip_xwalk$place), "�")),
  "no PR municipio retained its diacritic — encoding regression" =
    any(zip_xwalk$county == utf8_literal("Añasco"))
)
# 2020 has ~33,650 ZCTAs
stopifnot(between(n_distinct(zip_xwalk$zcta), 32000, 34000))

arrow::write_parquet(zip_xwalk, "data/zip-xwalk.parquet")
