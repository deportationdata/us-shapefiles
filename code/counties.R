#!/usr/bin/env Rscript
# Counties (geoid, stusps, name, namelsad, geometry) from the GEO_VINTAGE cartographic
# boundary file; name is NAMELSAD minus " County" (minus any type in the territories).

source("code/utils.R")

counties_sf <-
  tigris::counties(cb = TRUE, resolution = "500k", year = GEO_VINTAGE) |>
  transmute(geoid = GEOID, stusps = STUSPS, name = county_name(NAMELSAD, STATEFP), namelsad = NAMELSAD) |>
  st_transform(4326) |>
  arrange(geoid)

stopifnot(
  all(validUTF8(counties_sf$name)),
  !any(str_detect(counties_sf$name, "�")),
  "no PR municipio retained its diacritic — encoding regression" =
    any(counties_sf$name == utf8_literal("Añasco Municipio")),
  # two same-state counties with one normalized key would merge in name joins
  !anyDuplicated(paste(counties_sf$stusps, norm_geo_key(counties_sf$name)))
)

sf::st_write(counties_sf, dsn = "data/counties-sf.parquet", driver = "Parquet", layer_options = "USE_PARQUET_GEO_TYPES=ONLY", delete_dsn = file.exists("data/counties-sf.parquet"), quiet = TRUE)
