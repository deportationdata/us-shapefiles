#!/usr/bin/env Rscript
# Places (geoid, stusps, name, pop20, geometry) from the GEO_VINTAGE cartographic
# boundary file; pop20 is summed from data/blocks-xwalk.parquet, so run blocks.R first.

source("code/utils.R")

# state = NULL fetches the one national CB places file (needs a recent tigris).
cb_places <-
  tigris::places(state = NULL, cb = TRUE, year = GEO_VINTAGE) |>
  transmute(geoid = GEOID, stusps = STUSPS, name = place_name(NAMELSAD)) |>
  st_transform(4326)

pop_by_geoid <-
  arrow::read_parquet("data/blocks-xwalk.parquet") |>
  filter(!is.na(place_geoid)) |>
  summarise(pop20 = sum(pop20, na.rm = TRUE), .by = place_geoid)

# Every block's place must be in the CB universe, else the two vintages differ.
stopifnot(all(pop_by_geoid$place_geoid %in% cb_places$geoid))

places_df <-
  cb_places |>
  st_drop_geometry() |>
  left_join(pop_by_geoid, by = c("geoid" = "place_geoid")) |>
  mutate(pop20 = coalesce(pop20, 0L)) |>
  # places sharing a (state, normalized name) key: keep the more populous
  group_by(stusps, key = norm_geo_key(name)) |>
  slice_max(pop20, n = 1, with_ties = FALSE) |>
  ungroup() |>
  select(geoid, pop20)

stopifnot(
  !anyDuplicated(places_df$geoid),
  all(validUTF8(cb_places$name)),
  !any(str_detect(cb_places$name, "�")),
  "no PR place retained its diacritic — encoding regression" =
    any(cb_places$name == utf8_literal("Añasco zona urbana"))
)

places_sf <-
  cb_places |>
  inner_join(places_df, by = "geoid") |>
  select(geoid, stusps, name, pop20) |>
  arrange(geoid)
stopifnot(nrow(places_sf) == nrow(places_df))

sf::st_write(places_sf, dsn = "data/places-sf.parquet", driver = "Parquet", layer_options = "USE_PARQUET_GEO_TYPES=ONLY", delete_dsn = file.exists("data/places-sf.parquet"), quiet = TRUE)
