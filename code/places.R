#!/usr/bin/env Rscript
# Census places (geoid, stusps, name, pop20 + geometry), named the way the
# published EOIR data names them (the place transforms of
# eoir/scripts/geography_join.R on the same geocorr2022 / tab20 inputs —
# the extracts in inputs/ are copies of deportationdata/eoir's). The
# universe is the Census 2020 cartographic-boundary places file (500k, the
# only CB resolution published for places — the same place universe
# geocorr2022 indexes, and the national file carries the island
# territories), which also supplies the geometry. Where two distinct
# places normalize to the same (state, name) join key the EOIR data cannot
# tell them apart either; keep the more populous one.
#
# pop20 is each place's total 2020 Census population (geocorr; 0 where
# geocorr doesn't cover, i.e. the island territories) — a value-agnostic
# "how prominent is this place" attribute for consumers that need to rank
# places (e.g. which ones stay visible at national zooms).
#
# Geocorr CSVs are latin1 (PR place names carry diacritics, e.g. "Mayagüez
# zona urbana"); the tab20 relationship files are UTF-8 with a BOM, which
# readr's default UTF-8 read strips. Reading geocorr as UTF-8 doesn't error
# — readr just substitutes U+FFFD for the invalid bytes — so a wrong
# locale= here mojibakes names silently instead of failing loudly.

source("code/utils.R")

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

# Encoding guard: valid UTF-8 with no U+FFFD (a wrong locale= mojibakes
# without erroring — see above), plus a canary that at least one PR place
# still carries its diacritic, since a corrupted-but-valid string (e.g. two
# mangled bytes forming a different valid character) would pass the U+FFFD
# check alone.
stopifnot(
  "geocorr place names contain non-UTF-8 bytes or U+FFFD — check locale(encoding=) on the read_csv" =
    all(validUTF8(geocorr_places$name)) &&
      !any(str_detect(geocorr_places$name, "�")),
  "no PR place retained its diacritic — encoding regression" =
    any(geocorr_places$name == utf8_literal("Añasco zona urbana"))
)

# Each place's TOTAL population — summed over every geocorr row of the
# geoid, before any name filtering — distinct from geocorr_places$pop20
# (per name variant), which only ranks the join-key dedup below.
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

# state = NULL fetches the one national CB places file (needs a recent
# tigris — older versions only fetch places state by state).
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
# Every attribute row must carry a polygon — a miss means geocorr/tab20
# and the CB file disagree about the place universe.
stopifnot(nrow(places_sf) == nrow(places_df))

st_write_parquet(places_sf, "data/places-sf.parquet")
