#!/usr/bin/env Rscript
# Counties named as the EOIR data names them (eoir/scripts/geography_join.R).

source("code/utils.R")

# Geocorr is latin1; reading it as UTF-8 mojibakes silently.
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
    name = coalesce(name, str_squish(str_remove(NAMELSAD, " County$")))
  ) |>
  transmute(geoid = GEOID, stusps = STUSPS, name) |>
  st_transform(4326) |>
  arrange(geoid)

stopifnot(!anyDuplicated(paste(
  counties_sf$stusps, norm_geo_key(counties_sf$name)
)))

sf::st_write(counties_sf, dsn = "data/counties-sf.parquet", driver = "Parquet", layer_options = "USE_PARQUET_GEO_TYPES=ONLY", delete_dsn = file.exists("data/counties-sf.parquet"), quiet = TRUE)
