#!/usr/bin/env Rscript
# Each 2020 ZCTA → the county and place holding most of its 2020 population
# (land area in the island territories), from data/blocks-xwalk.parquet.

source("code/utils.R")

counties <-
  tigris::counties(cb = TRUE, resolution = "500k", year = GEO_VINTAGE) |>
  st_drop_geometry() |>
  transmute(county_geoid = GEOID, stusps = STUSPS,
            county = county_name(NAMELSAD, STATEFP))

# state = NULL fetches the one national CB places file (needs a recent tigris).
places <-
  tigris::places(state = NULL, cb = TRUE, year = GEO_VINTAGE) |>
  st_drop_geometry() |>
  transmute(place_geoid = GEOID, place = place_name(NAMELSAD))

# Weight is 2020 population; a ZCTA with none (the territories' blocks carry no
# POP20) is weighted by land area instead.
blocks <-
  arrow::read_parquet("data/blocks-xwalk.parquet") |>
  filter(!is.na(zcta)) |>
  mutate(by_pop = sum(pop20, na.rm = TRUE) > 0, .by = zcta) |>
  mutate(w = if_else(by_pop, coalesce(as.numeric(pop20), 0), aland))

# Largest share of the ZCTA's weight; ties to the lowest code (NA sorts last).
largest_share <- function(d, geo) {
  d |>
    summarise(w = sum(w), .by = c(zcta, {{ geo }})) |>
    arrange(zcta, desc(w), {{ geo }}) |>
    distinct(zcta, .keep_all = TRUE) |>
    select(-w)
}

zcta_county <- largest_share(blocks, county_geoid)

# Blocks in no place compete state by state, as a "no place" code per state;
# on land-area ZCTAs only places compete.
zcta_place <-
  blocks |>
  filter(by_pop | !is.na(place_geoid)) |>
  mutate(key = coalesce(place_geoid, str_c(str_sub(county_geoid, 1, 2), "99999"))) |>
  largest_share(key) |>
  transmute(zcta, place_geoid = if_else(str_ends(key, "99999"), NA_character_, key))

zip_xwalk <-
  zcta_county |>
  left_join(zcta_place, by = "zcta") |>
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
    any(zip_xwalk$county == utf8_literal("Añasco Municipio"))
)
# 2020 has ~33,650 ZCTAs
stopifnot(between(n_distinct(zip_xwalk$zcta), 32000, 34000))

arrow::write_parquet(zip_xwalk, "data/zip-xwalk.parquet")
