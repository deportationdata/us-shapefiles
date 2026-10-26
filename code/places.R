#!/usr/bin/env Rscript
# Places named as the EOIR data names them (eoir/scripts/geography_join.R);
# places sharing a join key keep the more populous one.

source("code/utils.R")

# Geocorr is latin1; reading it as UTF-8 mojibakes silently.
geocorr_raw <-
  read_csv("inputs/geocorr2022_2607609986_place.csv",
           locale = locale(encoding = "latin1"),
           show_col_types = FALSE) |>
  slice(-1)

geocorr_places <-
  geocorr_raw |>
  type_convert(col_types = cols()) |>
  filter(str_detect(place, "^\\d{5}$"), place != "99999") |>
  mutate(
    geoid = paste0(str_pad(state, 2, pad = "0"), place),
    name = PlaceName |>
      str_remove(",? [A-Z]{2}$") |>
      str_remove("\\s*\\(.*\\)") |>
      str_squish()
  ) |>
  filter(name != "", !str_starts(name, fixed("["))) |>
  group_by(geoid, stusps = stab, name) |>
  summarize(pop20 = sum(suppressWarnings(as.numeric(pop20)), na.rm = TRUE),
            .groups = "drop")

stopifnot(
  "geocorr place names contain non-UTF-8 bytes or U+FFFD — check locale(encoding=) on the read_csv" =
    all(validUTF8(geocorr_places$name)) &&
      !any(str_detect(geocorr_places$name, "�")),
  "no PR place retained its diacritic — encoding regression" =
    any(geocorr_places$name == utf8_literal("Añasco zona urbana"))
)

# Total per geoid; geocorr_places$pop20 is per name variant.
pop_by_geoid <-
  geocorr_raw |>
  filter(str_detect(place, "^\\d{5}$"), place != "99999") |>
  mutate(
    geoid = paste0(str_pad(state, 2, pad = "0"), place),
    pop20 = suppressWarnings(as.numeric(pop20))
  ) |>
  group_by(geoid) |>
  summarise(pop20 = sum(pop20, na.rm = TRUE))

territory_places <-
  read_delim("inputs/tab20_zcta520_place20_natl.txt",
             delim = "|",
             show_col_types = FALSE) |>
  filter(str_sub(GEOID_PLACE_20, 1, 2) %in% TERRITORY_FIPS) |>
  distinct(GEOID_PLACE_20, NAMELSAD_PLACE_20) |>
  transmute(
    geoid = GEOID_PLACE_20,
    stusps = c("60" = "AS", "66" = "GU", "69" = "MP", "78" = "VI")[
      str_sub(geoid, 1, 2)
    ],
    name = NAMELSAD_PLACE_20 |>
      str_remove("\\s*\\(.*\\)") |>
      str_squish(),
    pop20 = 0
  )

# state = NULL needs a recent tigris.
cb_places <-
  tigris::places(state = NULL, cb = TRUE, year = 2020) |>
  transmute(geoid = GEOID) |>
  st_transform(4326)

places_df <-
  bind_rows(geocorr_places,
            anti_join(territory_places, geocorr_places, by = "geoid")) |>
  filter(geoid %in% cb_places$geoid) |>
  group_by(stusps, key = norm_geo_key(name)) |>
  slice_max(pop20, n = 1, with_ties = FALSE) |>
  ungroup() |>
  select(geoid, stusps, name) |>
  arrange(geoid)

stopifnot(!anyDuplicated(places_df$geoid))

places_sf <-
  places_df |>
  left_join(pop_by_geoid, by = "geoid") |>
  mutate(pop20 = coalesce(pop20, 0)) |>
  inner_join(cb_places, by = "geoid") |>
  st_as_sf()
stopifnot(nrow(places_sf) == nrow(places_df))

sf::st_write(places_sf, dsn = "data/places-sf.parquet", driver = "Parquet", layer_options = "USE_PARQUET_GEO_TYPES=ONLY", delete_dsn = file.exists("data/places-sf.parquet"), quiet = TRUE)
