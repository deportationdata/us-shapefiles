#!/usr/bin/env Rscript
# Counties from the geo_vintage CB file. name is the Census NAME, which an
# independent city and the county around it share (Richmond, VA): join on geoid.

source("code/utils.R")

county_areas <-
  tigris::counties(cb = FALSE, year = geo_vintage) |>
  st_drop_geometry() |>
  transmute(
    geoid = GEOID,
    cbsa_geoid = na_if(CBSAFP, ""),
    csa_geoid = na_if(CSAFP, "")
  )

counties_sf <-
  tigris::counties(cb = TRUE, resolution = "500k", year = geo_vintage) |>
  transmute(geoid = GEOID, stusps = STUSPS, name = NAME, namelsad = NAMELSAD) |>
  left_join(county_areas, by = "geoid") |>
  st_transform(4326) |>
  arrange(geoid)

stopifnot(
  !anyNA(counties_sf$geoid),
  !anyDuplicated(counties_sf$geoid),
  !any(st_is_empty(counties_sf)),
  st_crs(counties_sf) == st_crs(4326),
  all(counties_sf$geoid %in% county_areas$geoid),
  all(is.na(counties_sf$cbsa_geoid) | str_detect(counties_sf$cbsa_geoid, "^[0-9]{5}$")),
  all(is.na(counties_sf$csa_geoid) | !is.na(counties_sf$cbsa_geoid)),
  all(validUTF8(counties_sf$name)),
  !any(str_detect(counties_sf$name, "�")),
  "no PR municipio retained its diacritic — encoding problem" = any(
    counties_sf$name == utf8_literal("Añasco")
  )
)

sf::st_write(
  counties_sf,
  dsn = "data/counties-sf.parquet",
  driver = "Parquet",
  layer_options = "USE_PARQUET_GEO_TYPES=ONLY",
  delete_dsn = file.exists("data/counties-sf.parquet"),
  quiet = TRUE
)
