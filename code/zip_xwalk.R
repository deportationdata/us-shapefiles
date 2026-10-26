#!/usr/bin/env Rscript
# ZCTA -> county/place crosswalk (eoir/scripts/geography_join.R): geocorr
# afact for states + PR, tab20 land area for the island territories.

source("code/utils.R")

# Geocorr's CountyName sometimes omits the state, so key on FIPS.
state_fips_lookup <-
  tigris::states(cb = TRUE, resolution = "500k", year = 2024) |>
  st_drop_geometry() |>
  transmute(state_fips_code = GEOID, stusps = STUSPS)

zcta_county <-
  read_csv(
    "inputs/geocorr2022_2607608761_county.csv",
    locale = locale(encoding = "latin1"),
    show_col_types = FALSE
  ) |>
  slice(-1) |>
  type_convert(col_types = cols()) |>
  filter(!is.na(zcta), str_detect(zcta, "^\\d+$")) |>
  group_by(zcta) |>
  slice_max(afact, n = 1, with_ties = FALSE) |>
  ungroup() |>
  transmute(
    zcta,
    state_fips_code = str_sub(str_pad(county, 5, pad = "0"), 1, 2),
    county_geoid = str_pad(county, 5, pad = "0"),
    county = str_remove(CountyName, ",? [A-Z]{2}(\\s*\\(.*\\))?$") |>
      str_squish()
  ) |>
  left_join(state_fips_lookup, by = "state_fips_code") |>
  select(-state_fips_code)

zcta_place <-
  read_csv(
    "inputs/geocorr2022_2607609986_place.csv",
    locale = locale(encoding = "latin1"),
    show_col_types = FALSE
  ) |>
  slice(-1) |>
  type_convert(col_types = cols()) |>
  filter(!is.na(zcta), str_detect(zcta, "^\\d+$")) |>
  group_by(zcta) |>
  slice_max(afact, n = 1, with_ties = FALSE) |>
  ungroup() |>
  transmute(
    zcta,
    place_geoid = if_else(
      place == "99999",
      NA_character_,
      paste0(str_pad(state, 2, pad = "0"), place)
    ),
    place = if_else(
      place == "99999",
      NA_character_,
      PlaceName |>
        str_remove(",? [A-Z]{2}$") |>
        str_remove("\\s*\\(.*\\)") |>
        str_squish()
    )
  )

territory_county <-
  read_delim(
    "inputs/tab20_zcta520_county20_natl.txt",
    delim = "|",
    show_col_types = FALSE
  ) |>
  filter(
    !is.na(GEOID_ZCTA5_20),
    str_sub(GEOID_COUNTY_20, 1, 2) %in% TERRITORY_FIPS
  ) |>
  group_by(GEOID_ZCTA5_20) |>
  slice_max(AREALAND_PART, n = 1, with_ties = FALSE) |>
  ungroup() |>
  transmute(
    zcta = GEOID_ZCTA5_20,
    state_fips_code = str_sub(GEOID_COUNTY_20, 1, 2),
    county_geoid = GEOID_COUNTY_20,
    county = str_remove(
      NAMELSAD_COUNTY_20,
      " (County|Borough|Census Area|Municipality|District|Island|Municipio)$"
    )
  ) |>
  left_join(state_fips_lookup, by = "state_fips_code") |>
  select(-state_fips_code)

territory_place <-
  read_delim(
    "inputs/tab20_zcta520_place20_natl.txt",
    delim = "|",
    show_col_types = FALSE
  ) |>
  filter(
    !is.na(GEOID_ZCTA5_20),
    str_sub(GEOID_PLACE_20, 1, 2) %in% TERRITORY_FIPS
  ) |>
  group_by(GEOID_ZCTA5_20) |>
  slice_max(AREALAND_PART, n = 1, with_ties = FALSE) |>
  ungroup() |>
  transmute(
    zcta = GEOID_ZCTA5_20,
    place_geoid = GEOID_PLACE_20,
    place = NAMELSAD_PLACE_20 |>
      str_remove("\\s*\\(.*\\)") |>
      str_squish()
  )

territory_lookup <- left_join(territory_county, territory_place, by = "zcta")

zip_xwalk <-
  left_join(zcta_county, zcta_place, by = "zcta") |>
  bind_rows(territory_lookup) |>
  transmute(zcta, stusps, county, county_geoid, place, place_geoid) |>
  arrange(zcta)

stopifnot(
  !anyDuplicated(zip_xwalk$zcta),
  all(str_detect(zip_xwalk$zcta, "^\\d{5}$")),
  all(!is.na(zip_xwalk$stusps)),
  "zip_xwalk names contain non-UTF-8 bytes or U+FFFD — check locale(encoding=) on the read_csv" = all(validUTF8(
    zip_xwalk$county
  )) &&
    !any(str_detect(zip_xwalk$county, "�")) &&
    all(validUTF8(na.omit(zip_xwalk$place))) &&
    !any(str_detect(na.omit(zip_xwalk$place), "�")),
  "no PR municipio retained its diacritic — encoding regression" = any(
    zip_xwalk$county == utf8_literal("Añasco Municipio")
  )
)
# 2020 has ~33,120 ZCTAs
stopifnot(between(n_distinct(zip_xwalk$zcta), 32000, 34000))

arrow::write_parquet(zip_xwalk, "data/zip-xwalk.parquet")
