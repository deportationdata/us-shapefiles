#!/usr/bin/env Rscript
# Counties (geoid, stusps, name + geometry), named the way the published
# EOIR data names them so EOIR county values join by construction. The
# names replicate eoir/scripts/geography_join.R:
#   50 states + DC + PR: geocorr CountyName minus the trailing ",? ST"
#     (geocorr drops " County" but keeps Parish/city/Borough/…; CT is the
#     2022 planning regions)
#   AS/GU/MP/VI: tab20 NAMELSAD minus the type suffix
# The county universe and geometry are the Census 500k cartographic-
# boundary file — the finest published series, and the national file that
# carries the island territories the coarser 20m series lacks. The
# geocorr/tab20 extracts in inputs/ are copies of the same files
# deportationdata/eoir builds from (its inputs/).

source("code/utils.R")

geocorr_county_names <-
  read_csv("inputs/geocorr2022_2607608761_county.csv",
           show_col_types = FALSE) |>
  slice(-1) |>
  filter(str_detect(county, "^\\d{5}$")) |>
  distinct(county, CountyName) |>
  transmute(
    geoid = county,
    name = CountyName |>
      str_remove(",? [A-Z]{2}(\\s*\\(.*\\))?$") |>
      str_squish()
  )

territory_county_names <-
  read_delim("inputs/tab20_zcta520_county20_natl.txt",
             delim = "|",
             locale = locale(encoding = "latin1"),
             show_col_types = FALSE) |>
  filter(str_sub(GEOID_COUNTY_20, 1, 2) %in% TERRITORY_FIPS) |>
  distinct(GEOID_COUNTY_20, NAMELSAD_COUNTY_20) |>
  transmute(
    geoid = GEOID_COUNTY_20,
    name = str_remove(
      NAMELSAD_COUNTY_20,
      " (County|Borough|Census Area|Municipality|District|Island|Municipio)$"
    )
  )

eoir_county_names <- bind_rows(geocorr_county_names, territory_county_names)

# A vintage that ships latin1 (PR municipios carry diacritics) would pass
# invalid bytes through and mojibake display names downstream — fail at
# build time.
stopifnot(
  "geocorr county names contain non-UTF-8 bytes — set locale(encoding=) on the read_csv" =
    all(validUTF8(eoir_county_names$name))
)

counties_sf <-
  read_cb("cb_2024_us_county_500k", 2024) |>
  left_join(eoir_county_names, by = c("GEOID" = "geoid")) |>
  mutate(
    # Counties absent from geocorr/tab20 fall back to the same transform
    # geocorr applies to plain counties.
    name = coalesce(name, str_squish(str_remove(NAMELSAD, " County$")))
  ) |>
  transmute(geoid = GEOID, stusps = STUSPS, name) |>
  st_transform(4326) |>
  arrange(geoid)

# Two same-state counties collapsing to one normalized join key would
# silently merge in name-keyed joins downstream.
stopifnot(!anyDuplicated(paste(
  counties_sf$stusps, norm_geo_key(counties_sf$name)
)))

sfarrow::st_write_parquet(counties_sf, "data/counties-sf.parquet")
write_shp_zip(counties_sf, "counties")
