#!/usr/bin/env Rscript
# Counties from the geo_vintage CB file. name is the Census NAME, which an
# independent city and the county around it share (Richmond, VA): join on geoid.

source("code/utils.R")

counties_sf <-
  tigris::counties(cb = TRUE, resolution = "500k", year = geo_vintage) |>
  transmute(geoid = GEOID, stusps = STUSPS, name = NAME, namelsad = NAMELSAD) |>
  st_transform(4326) |>
  arrange(geoid)

stopifnot(
  all(validUTF8(counties_sf$name)),
  !any(str_detect(counties_sf$name, "�")),
  "no PR municipio retained its diacritic — encoding regression" = any(
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
