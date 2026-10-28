#!/usr/bin/env Rscript
# Places from the geo_vintage CB file; pop20 is summed from
# data/blocks-xwalk.parquet, so run blocks.R first. name is the Census NAME,
# which a town and a CDP in one state can share (Midway, AR): join on geoid.

source("code/utils.R")

# state = NULL fetches the one national CB places file (needs a recent tigris).
cb_places <-
  tigris::places(state = NULL, cb = TRUE, year = geo_vintage) |>
  transmute(
    geoid = GEOID,
    stusps = STUSPS,
    name = NAME,
    namelsad = NAMELSAD,
    lsad = LSAD,
    aland = ALAND
  ) |>
  st_transform(4326)

# The Census names a consolidated city minus its semi-independent municipalities
# "<government> (balance)"; a display using short_name should footnote that.
balance_short_names <- tribble(
  ~geoid,    ~short_name,
  "0947515", "Milford",      # minus Woodmont borough
  "1303440", "Athens",       # minus Winterville and part of Bogart
  "1304204", "Augusta",      # minus Hephzibah and Blythe
  "1836003", "Indianapolis", # minus Beech Grove, Lawrence, Southport, Speedway
  "2148006", "Louisville",   # minus 83 cities; holds half of Jefferson County
  "3011397", "Butte",        # minus Walkerville
  "4752006", "Nashville",    # minus Belle Meade, Berry Hill, Forest Hills, Oak
                             # Hill and parts of Goodlettsville and Ridgetop
  # 410 rural residents, with Tribune and Horace both outside: no short form
  "2028412", "Greeley County unified government (balance)"
)

pop_by_place <-
  arrow::read_parquet("data/blocks-xwalk.parquet") |>
  filter(!is.na(place_geoid)) |>
  summarise(pop20 = sum(pop20, na.rm = TRUE), .by = place_geoid)

# Every block's place must be in the CB universe, else the two vintages differ.
stopifnot(all(pop_by_place$place_geoid %in% cb_places$geoid))

stopifnot(
  "balance_short_names and the (balance) places differ" = setequal(
    balance_short_names$geoid,
    filter(cb_places, str_detect(name, fixed("(balance)")))$geoid
  ),
  !anyDuplicated(cb_places$geoid),
  all(validUTF8(cb_places$name)),
  !any(str_detect(cb_places$name, "�")),
  "no PR place retained its diacritic — encoding regression" = any(
    cb_places$name == utf8_literal("Añasco")
  )
)

places_sf <-
  cb_places |>
  left_join(pop_by_place, by = c("geoid" = "place_geoid")) |>
  mutate(pop20 = coalesce(pop20, 0L)) |> # a place with no populated block
  left_join(balance_short_names, by = "geoid") |>
  mutate(short_name = coalesce(short_name, name)) |>
  select(geoid, stusps, name, namelsad, short_name, lsad, aland, pop20) |>
  arrange(geoid)

sf::st_write(
  places_sf,
  dsn = "data/places-sf.parquet",
  driver = "Parquet",
  layer_options = "USE_PARQUET_GEO_TYPES=ONLY",
  delete_dsn = file.exists("data/places-sf.parquet"),
  quiet = TRUE
)
