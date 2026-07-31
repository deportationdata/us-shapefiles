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

# Geocorr CSVs are latin1 (PR municipios carry diacritics, e.g. "Añasco
# Municipio"); the tab20 relationship files are UTF-8 with a BOM, which
# readr's default UTF-8 read strips. Reading geocorr as UTF-8 doesn't error —
# readr just substitutes U+FFFD for the invalid bytes — so a wrong locale=
# here mojibakes names silently instead of failing loudly.
geocorr_county_names <-
  read_csv("inputs/geocorr2022_2607608761_county.csv",
           locale = locale(encoding = "latin1"),
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

# Encoding guard: valid UTF-8 with no U+FFFD (a wrong locale= mojibakes
# without erroring — see above), plus a canary that at least one PR
# municipio still carries its diacritic, since a corrupted-but-valid string
# (e.g. two mangled bytes forming a different valid character) would pass
# the U+FFFD check alone.
stopifnot(
  "geocorr county names contain non-UTF-8 bytes or U+FFFD — check locale(encoding=) on the read_csv" =
    all(validUTF8(eoir_county_names$name)) &&
      !any(str_detect(eoir_county_names$name, "�")),
  "no PR municipio retained its diacritic — encoding regression" =
    any(eoir_county_names$name == utf8_literal("Añasco Municipio"))
)

counties_sf <-
  tigris::counties(cb = TRUE, resolution = "500k", year = 2024) |>
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

st_write_parquet(counties_sf, "data/counties-sf.parquet")
