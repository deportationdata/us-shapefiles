#!/usr/bin/env Rscript
# ZIP (ZCTA) -> county / place crosswalk, geoid-keyed to counties-sf.parquet
# and places-sf.parquet so it joins those files directly (no norm_geo_key
# needed). Replicates eoir/scripts/geography_join.R's ZCTA allocation on the
# same geocorr/tab20 inputs counties.R and places.R read:
#   50 states + DC + PR: geocorr's zcta-to-county/place allocation factor
#     (afact) — largest population share wins ties
#   AS/GU/MP/VI: tab20 land-area share (geocorr does not cover territories)
# Unlike geography_join.R's zip_lookup (name-keyed, matching the published
# EOIR columns), county/place names here are carried only for readability.
# A handful of place_geoid values point at a same-named CDP places.R's own
# (state, norm_geo_key(name)) dedup dropped in favor of a more populous
# twin — join places-sf.parquet by name in that case, same as EOIR data.

source("code/utils.R")

# State FIPS -> stusps, from the same Census cartographic file states.R
# builds from. Geocorr's CountyName occasionally drops the trailing state
# abbreviation entirely (e.g. AK's Hoonah-Angoon Census Area), so the FIPS
# prefix of `county`/GEOID_COUNTY_20 is the reliable state key, not the name.
state_fips_lookup <-
  tigris::states(cb = TRUE, resolution = "500k", year = 2024) |>
  st_drop_geometry() |>
  transmute(state_fips_code = GEOID, stusps = STUSPS)

# --- ZCTA -> county (population-weighted allocation) ---
zcta_county <-
  read_csv("inputs/geocorr2022_2607608761_county.csv",
           show_col_types = FALSE) |>
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

# --- ZCTA -> place (population-weighted allocation) ---
zcta_place <-
  read_csv("inputs/geocorr2022_2607609986_place.csv",
           show_col_types = FALSE) |>
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

# --- Territory supplement (AS, GU, MP, VI), area-weighted from tab20 ---
# Geocorr covers 50 states + DC + PR; territories need the Census
# relationship files counties.R/places.R also read for their territory rows.
territory_county <-
  read_delim("inputs/tab20_zcta520_county20_natl.txt",
             delim = "|",
             locale = locale(encoding = "latin1"),
             show_col_types = FALSE) |>
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
  read_delim("inputs/tab20_zcta520_place20_natl.txt",
             delim = "|",
             locale = locale(encoding = "latin1"),
             show_col_types = FALSE) |>
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

# A dup zcta or an NA stusps means an allocation-factor tie broke wrong, or
# a county/state FIPS code fell outside the states.R cartographic file.
stopifnot(
  !anyDuplicated(zip_xwalk$zcta),
  all(str_detect(zip_xwalk$zcta, "^\\d{5}$")),
  all(!is.na(zip_xwalk$stusps))
)
# 2020 Census has ~33,120 ZCTAs; a big miss means an input didn't load.
stopifnot(between(n_distinct(zip_xwalk$zcta), 32000, 34000))

arrow::write_parquet(zip_xwalk, "data/zip-xwalk.parquet")
