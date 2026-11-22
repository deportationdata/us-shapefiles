#!/usr/bin/env Rscript
# Divides the United States into non-overlapping cells built from Census places
# and county subdivisions, and writes a geoid → cell crosswalk.
# A place folds into the subdivision cell holding most of its residents; a
# subdivision lifts into the place cell holding it.
#   1. A Census place is a cell.
#   2. In twelve states the town or township is the cell. A place inside it
#      folds into it when it carries the town's name; a place with another
#      name is its own cell and the town keeps the remainder. A municipality
#      covering a whole subdivision is one cell with it.
#   3. In AS, MP and VI the county equivalent is the cell; in Guam, the
#      municipality.
#   4. Land in no place cell is its subdivision's remainder. District and
#      precinct remainders merge by county.

source("code/utils.R")

sf_use_s2(FALSE)

# The twelve states whose towns and townships "serve as general-purpose local
# governments that can perform the same governmental functions as incorporated
# places" (2020 PL 94-171 technical documentation, App. A, pp. A-21 to A-22).
# A municipality covering a whole subdivision folds into it in town_states and
# stays a place cell, the subdivision lifted into it, in place_cell_states.
town_states <- c("ME", "NH", "VT", "MA", "RI", "CT", "NJ", "PA")
new_england <- c("ME", "NH", "VT", "MA", "RI", "CT")
place_cell_states <- c("NY", "MI", "WI", "MN")

# Eight more states have active townships that overlie cities. Only used in a
# check below.
active_township_states <- c("IL", "IN", "KS", "MO", "NE", "ND", "OH", "SD")
active_township_classfp <- c("T1", "T5")

# A consolidated government's old city joins its "(balance)" place as one cell.
consolidated_merges <- tribble(
  ~geoid,    ~merged_into,
  "2148000", "2148006" # Louisville city into Louisville/Jefferson County metro
)

# A CDP in unorganized territory has no town to fold into, so it stays a cell.
unorganized_lsad <- "46"

# Branford Center CDP in Branford town carries the town's name.
town_centre_suffix <- " (Center|Village|Town)$"

# Island villages are far smaller than mainland cells.
county_cell_states <- c("AS", "MP", "VI")
always_fold_states <- c(county_cell_states, "GU")

# Districts and precincts are not place names (over half carry only a number
# or letter). 99999 is the Census's own remainder code.
district_lsad <- c("27", "28", "29", "30")
county_remainder_code <- "99999"

# A subdivision lifts if a place holds >= lift_share_min of its area. One that
# keeps >= whole_share of its area is untouched. A remainder under sliver_m2,
# or under sliver_share and narrower than sliver_width_m, is dropped.
lift_share_min <- 0.95
whole_share <- 0.99999
sliver_m2 <- 10000
sliver_share <- 0.01
sliver_width_m <- 50

# Coverage check, in m2. Dropping slivers leaves holes, so a state may have up
# to gap_max_m2 uncovered (now 0.48 km2 at most, in TN); cells may overlap or
# leave their state by overlap_max_m2.
gap_max_m2 <- 1e6
overlap_max_m2 <- 100

# Presque Isle Bay (Erie County, PA, 12.4 km2 of water, no land or people) is
# inside the CB state and county polygons, but the Census puts it in no
# subdivision (code 00000, "not defined"), which the CB subdivision file
# leaves out; the cells inherit the hole.
known_holes_m2 <- c(PA = 12.44e6)

places <-
  st_read("data/places-sf.parquet", quiet = TRUE) |>
  transmute(
    geoid,
    stusps,
    name,
    namelsad,
    short_name,
    is_cdp = str_ends(namelsad, "CDP"),
    funcstat,
    classfp,
    county_geoid = NA_character_, # a place can span counties
    aland,
    geometry
  ) |>
  st_make_valid()

county_subdivisions <-
  st_read("data/county-subdivisions-sf.parquet", quiet = TRUE) |>
  st_make_valid()

stopifnot(
  "the states with active towns or townships are not the twelve plus active_township_states" = setequal(
    setdiff(
      county_subdivisions$stusps[
        county_subdivisions$classfp %in% active_township_classfp
      ],
      always_fold_states # American Samoa's counties are active
    ),
    c(town_states, place_cell_states, active_township_states)
  ),
  "a place has a class code cell_type does not know" = all(
    places$classfp %in%
      c("C1", "C2", "C5", "C6", "C7", "C8", "C9", "M2", "U1", "U2")
  ),
  "a place's status and class codes disagree on whether it is statistical" = all(
    (places$funcstat == "S") == str_detect(places$classfp, "^[MU]")
  ),
  "a subdivision has a class code cell_type does not know" = all(
    county_subdivisions$classfp %in%
      c("C2", "C5", "T1", "T5", "T9", "Z1", "Z2", "Z3", "Z5", "Z7")
  )
)

counties <-
  st_read("data/counties-sf.parquet", quiet = TRUE) |>
  st_make_valid()

county_cells <-
  counties |>
  filter(stusps %in% county_cell_states) |>
  transmute(
    geoid,
    stusps,
    name,
    namelsad,
    geo_level = "county",
    county_geoid = geoid,
    geometry
  )

blocks <-
  arrow::read_parquet(
    "data/blocks-xwalk.parquet",
    col_select = c(
      "pop20",
      "aland",
      "county_geoid",
      "place_geoid",
      "county_subdivision_geoid"
    )
  ) |>
  mutate(pop20 = coalesce(pop20, 0L))

# Geodesic measures via s2 directly, without toggling sf_use_s2() per call.
geod_area <- function(g) s2::s2_area(st_as_s2(g))
geod_perimeter <- function(g) s2::s2_perimeter(st_as_s2(g))

# A municipality split by a county line becomes one place cell: a subdivision
# geoid is state + county + code, and in the town states a municipality's code
# is its place code, so state + code is the place geoid its pieces share.
split_pieces <-
  county_subdivisions |>
  as_tibble() |>
  filter(stusps %in% town_states) |>
  transmute(
    geoid,
    merged_geoid = str_c(str_sub(geoid, 1, 2), str_sub(geoid, 6, 10))
  ) |>
  semi_join(st_drop_geometry(places), by = c("merged_geoid" = "geoid")) |>
  filter(n() > 1, .by = merged_geoid)

# a shared code must be the same municipality, not a collision
stopifnot(all(
  split_pieces |>
    left_join(
      county_subdivisions |>
        as_tibble() |>
        select(geoid, county_subdivision_name = name),
      by = "geoid"
    ) |>
    left_join(
      places |> as_tibble() |> select(merged_geoid = geoid, place_name = name),
      by = "merged_geoid"
    ) |>
    mutate(same = county_subdivision_name == place_name) |>
    pull(same)
))

merged_place_cells <-
  county_subdivisions |>
  inner_join(split_pieces, by = "geoid") |>
  group_by(geoid = merged_geoid, stusps) |>
  summarize(geometry = st_union(geometry), .groups = "drop") |>
  st_make_valid() |>
  left_join(
    places |>
      as_tibble() |>
      select(geoid, name, namelsad, short_name, funcstat, classfp),
    by = "geoid"
  ) |>
  mutate(geo_level = "place", county_geoid = NA_character_)

# the rejoined pieces must be the place polygon, not merely share its code
stopifnot(all(
  merged_place_cells |>
    select(geoid, geometry) |>
    inner_join(
      places |> as_tibble() |> select(geoid, place_geometry = geometry),
      by = "geoid"
    ) |>
    mutate(
      inter_m2 = s2::s2_area(
        s2::s2_intersection(st_as_s2(geometry), st_as_s2(place_geometry))
      ),
      place_m2 = geod_area(place_geometry),
      same = (geod_area(geometry) + place_m2 - 2 * inter_m2) / place_m2 < 1e-4
    ) |>
    pull(same)
))

unsplit <-
  county_subdivisions |>
  filter(!stusps %in% county_cell_states) |>
  anti_join(split_pieces, by = "geoid")

# fold targets: subdivisions, with a split municipality's pieces as one
fold_units <- bind_rows(
  unsplit |> select(geoid, geometry),
  merged_place_cells |> select(geoid, geometry),
  county_cells |> select(geoid, geometry)
)

# A candidate folds into the unit with most of its 2020 residents, or most of
# its area if it has no residents.
fold_candidates <-
  places |>
  filter(stusps %in% c(town_states, place_cell_states, always_fold_states)) |>
  anti_join(st_drop_geometry(merged_place_cells), by = "geoid")

fold_area <-
  fold_candidates |>
  mutate(whole_m2 = geod_area(geometry)) |>
  st_intersection(
    fold_units |>
      mutate(unit_m2 = geod_area(geometry)) |>
      select(cell_geoid = geoid, unit_m2)
  ) |>
  suppressWarnings() |>
  st_make_valid() |>
  mutate(
    area_share = geod_area(geometry) / whole_m2,
    unit_share = geod_area(geometry) / unit_m2
  ) |>
  st_drop_geometry() |>
  select(geoid, cell_geoid, area_share, unit_share)

# Blocks in no defined subdivision (code 00000) are left out.
fold_pop <-
  blocks |>
  semi_join(st_drop_geometry(fold_candidates), by = c("place_geoid" = "geoid")) |>
  left_join(
    county_subdivisions |>
      as_tibble() |>
      left_join(split_pieces, by = "geoid") |>
      transmute(
        county_subdivision_geoid = geoid,
        cell_geoid = case_when(
          !is.na(merged_geoid) ~ merged_geoid,
          stusps %in% county_cell_states ~ county_geoid,
          TRUE ~ geoid
        )
      ),
    by = "county_subdivision_geoid"
  ) |>
  filter(!is.na(cell_geoid)) |>
  summarise(pop = sum(pop20), .by = c(place_geoid, cell_geoid)) |>
  rename(geoid = place_geoid)

fold_choice <-
  full_join(fold_area, fold_pop, by = c("geoid", "cell_geoid")) |>
  mutate(
    pop = coalesce(pop, 0L),
    area_share = coalesce(area_share, 0),
    unit_share = coalesce(unit_share, 0)
  ) |>
  arrange(geoid, desc(pop), desc(area_share), cell_geoid) |>
  slice_head(n = 1, by = geoid) |>
  left_join(
    county_subdivisions |>
      as_tibble() |>
      select(cell_geoid = geoid, lsad, cell_name = name),
    by = "cell_geoid"
  ) |>
  left_join(
    fold_candidates |> st_drop_geometry() |> select(geoid, stusps, is_cdp, place_name = name),
    by = "geoid"
  )

# A place stays a cell when its name is not its town's, unless it is a
# municipality covering the whole subdivision; so does a CDP in unorganized
# territory, and a municipality covering its subdivision in place_cell_states.
kept_places <-
  fold_choice |>
  mutate(
    own_name = place_name != cell_name &
      str_remove(place_name, town_centre_suffix) != cell_name,
    whole_unit = !is_cdp & unit_share >= lift_share_min
  ) |>
  filter(
    !stusps %in% always_fold_states,
    (is_cdp & lsad %in% unorganized_lsad) |
      (own_name & !whole_unit) |
      (whole_unit & stusps %in% place_cell_states)
  )

folded_cell <-
  fold_choice |>
  anti_join(kept_places, by = "geoid") |>
  select(geoid, cell_geoid)

place_cells <-
  places |>
  anti_join(st_drop_geometry(merged_place_cells), by = "geoid") |>
  anti_join(folded_cell, by = "geoid")

stopifnot(
  all(unlist(consolidated_merges) %in% place_cells$geoid),
  !anyDuplicated(consolidated_merges$geoid),
  !any(consolidated_merges$merged_into %in% consolidated_merges$geoid)
)
for (k in seq_len(nrow(consolidated_merges))) {
  from <- place_cells$geoid == consolidated_merges$geoid[k]
  into <- place_cells$geoid == consolidated_merges$merged_into[k]
  st_geometry(place_cells)[into] <-
    st_make_valid(st_union(st_geometry(place_cells)[from | into]))
  place_cells <- place_cells[!from, ]
}

# prep step for below to avoid cross-state issues
place_union <-
  place_cells |>
  group_by(stusps) |>
  summarize(geometry = st_union(geometry), .groups = "drop")

# Each unsplit subdivision minus its state's place cells: untouched ones stay
# subdivisions, cut ones become remainders, slivers are dropped, and one wholly
# inside places vanishes.
subdivision_cells <-
  unsplit |>
  mutate(full_m2 = geod_area(geometry)) |>
  group_by(stusps) |>
  group_modify(\(cs, state) {
    state_places <- semi_join(place_union, state, by = "stusps")
    # Guam has no place cells
    if (nrow(state_places) == 0) {
      return(cs)
    }
    st_difference(cs, st_geometry(state_places))
  }) |>
  ungroup() |>
  st_as_sf() |>
  suppressWarnings() |>
  st_make_valid() |>
  st_collection_extract("POLYGON", warn = FALSE) |>
  # a strip's width is about twice its area over its perimeter
  mutate(
    area_m2 = geod_area(geometry),
    width_m = 2 * area_m2 / geod_perimeter(geometry),
    subtracted = area_m2 < whole_share * full_m2,
    sliver = subtracted &
      (area_m2 < sliver_m2 |
        (area_m2 < sliver_share * full_m2 & width_m < sliver_width_m))
  ) |>
  filter(!sliver) |>
  mutate(
    geo_level = if_else(subtracted, "remainder", "county_subdivision"),
    namelsad = if_else(subtracted, str_c(namelsad, " (remainder)"), namelsad)
  ) |>
  select(-subtracted, -area_m2, -full_m2, -width_m, -sliver)

to_county_remainder <-
  subdivision_cells |>
  filter(
    lsad %in% district_lsad,
    !stusps %in% always_fold_states
  ) |>
  mutate(remainder_geoid = str_c(county_geoid, county_remainder_code))

county_remainder_of <-
  to_county_remainder |>
  st_drop_geometry() |>
  select(geoid, remainder_geoid)

county_remainder_cells <-
  to_county_remainder |>
  group_by(geoid = remainder_geoid, stusps, county_geoid) |>
  summarize(geometry = st_union(geometry), .groups = "drop") |>
  st_make_valid() |>
  left_join(
    counties |>
      st_drop_geometry() |>
      select(county_geoid = geoid, name, county_namelsad = namelsad),
    by = "county_geoid"
  ) |>
  mutate(
    namelsad = str_c(county_namelsad, " (remainder)"),
    geo_level = "county_remainder"
  ) |>
  select(-county_namelsad)

stopifnot(
  !anyNA(county_remainder_cells$namelsad),
  !any(county_remainder_cells$geoid %in% county_subdivisions$geoid),
  "a place folds into a district that is merged into its county" = !any(
    folded_cell$cell_geoid %in% county_remainder_of$geoid
  )
)

subdivision_cells <-
  subdivision_cells |>
  anti_join(county_remainder_of, by = "geoid")

cells <-
  bind_rows(
    place_cells |> mutate(geo_level = "place"),
    merged_place_cells,
    subdivision_cells,
    county_remainder_cells,
    county_cells
  ) |>
  # Describes the cell from the Census class and status codes; the rules above
  # do not depend on it.
  mutate(
    cell_type = case_when(
      geo_level == "county" ~ "county",
      geo_level == "county_remainder" ~ "county_remainder",
      geo_level == "place" & funcstat == "S" ~ "cdp",
      geo_level == "place" & classfp == "C9" ~ "inactive_municipality",
      geo_level == "place" ~ "municipality",
      classfp == "C5" ~ "municipality",
      classfp %in% active_township_classfp ~ "township",
      TRUE ~ "subdivision"
    )
  ) |>
  select(
    geoid,
    stusps,
    name,
    namelsad,
    geo_level,
    cell_type,
    county_geoid,
    geometry
  ) |>
  arrange(stusps, geo_level, geoid)

stopifnot(!anyDuplicated(cells$geoid))

is_cell <- cells |> st_drop_geometry() |> transmute(geoid, is_cell = TRUE)

# A place is its own cell (a split municipality as its merged pieces), else
# folds into its target when that survived as a cell (a subdivision lifted into
# a place is no longer there to fold into).
place_rows <-
  places |>
  left_join(is_cell, by = "geoid") |>
  left_join(
    folded_cell |>
      semi_join(is_cell, by = c("cell_geoid" = "geoid")) |>
      rename(folded_geoid = cell_geoid),
    by = "geoid"
  ) |>
  left_join(consolidated_merges, by = "geoid") |>
  mutate(
    cell_geoid = case_when(
      coalesce(is_cell, FALSE) ~ geoid,
      !is.na(merged_into) ~ merged_into,
      TRUE ~ folded_geoid
    ),
    rule = case_when(
      geoid %in% merged_place_cells$geoid ~ "cell: merged across county line",
      cell_geoid == geoid ~ "cell",
      !is.na(merged_into) ~ "merged into consolidated government",
      stusps %in% county_cell_states ~ "folded into county equivalent",
      !is.na(cell_geoid) ~ "folded into subdivision",
      TRUE ~ "no cell: its subdivision is covered by places"
    )
  ) |>
  select(-folded_geoid, -is_cell, -merged_into)

# A county subdivision with no remainder lifts into a place cell.
lift_area <-
  unsplit |>
  anti_join(st_drop_geometry(cells), by = "geoid") |>
  anti_join(county_remainder_of, by = "geoid") |>
  mutate(whole_area_m2 = geod_area(geometry)) |>
  st_intersection(place_cells |> select(cell_geoid = geoid)) |>
  suppressWarnings() |>
  st_make_valid() |>
  mutate(area_share = geod_area(geometry) / whole_area_m2) |>
  st_drop_geometry() |>
  select(geoid, cell_geoid, area_share)

lift_pop <-
  blocks |>
  semi_join(lift_area, by = c("county_subdivision_geoid" = "geoid")) |>
  # an old city's residents count for the cell it merged into
  left_join(consolidated_merges, by = c("place_geoid" = "geoid")) |>
  mutate(place_geoid = coalesce(merged_into, place_geoid)) |>
  semi_join(st_drop_geometry(place_cells), by = c("place_geoid" = "geoid")) |>
  summarise(pop = sum(pop20), .by = c(county_subdivision_geoid, place_geoid)) |>
  rename(geoid = county_subdivision_geoid, cell_geoid = place_geoid)

lifted_cell <-
  full_join(lift_area, lift_pop, by = c("geoid", "cell_geoid")) |>
  mutate(pop = coalesce(pop, 0L), area_share = coalesce(area_share, 0)) |>
  filter(any(area_share >= lift_share_min), .by = geoid) |>
  arrange(geoid, desc(pop), desc(area_share), cell_geoid) |>
  slice_head(n = 1, by = geoid) |>
  select(geoid, cell_geoid)

county_subdivision_rows <-
  county_subdivisions |>
  left_join(split_pieces, by = "geoid") |>
  left_join(lifted_cell |> rename(lifted_geoid = cell_geoid), by = "geoid") |>
  left_join(is_cell, by = "geoid") |>
  left_join(county_remainder_of, by = "geoid") |>
  mutate(
    cell_geoid = case_when(
      coalesce(is_cell, FALSE) ~ geoid,
      !is.na(merged_geoid) ~ merged_geoid,
      stusps %in% county_cell_states ~ county_geoid,
      !is.na(remainder_geoid) ~ remainder_geoid,
      TRUE ~ lifted_geoid
    ),
    rule = case_when(
      cell_geoid == geoid ~ "cell",
      !is.na(merged_geoid) ~ "merged across county line",
      stusps %in% county_cell_states ~ "folded into county equivalent",
      !is.na(remainder_geoid) ~ "merged into county remainder",
      !is.na(cell_geoid) ~ "lifted into place",
      TRUE ~ "no cell: covered by several places"
    )
  ) |>
  select(-merged_geoid, -lifted_geoid, -is_cell, -remainder_geoid)

# county cells are in the xwalk too, so a 5-digit island geoid finds its cell
county_rows <-
  county_cells |>
  left_join(
    county_subdivisions |>
      as_tibble() |>
      summarise(aland = sum(aland), .by = county_geoid),
    by = "county_geoid"
  ) |>
  mutate(cell_geoid = geoid, rule = "cell", is_cdp = FALSE)

xwalk <-
  bind_rows(
    place_rows |> mutate(geo_level = "place"),
    county_subdivision_rows |>
      mutate(geo_level = "county_subdivision", is_cdp = FALSE),
    county_rows
  ) |>
  st_drop_geometry() |>
  as_tibble() |>
  # a subdivision's short_name is its name; places bring theirs from places-sf
  mutate(short_name = coalesce(short_name, name)) |>
  select(
    geoid,
    geo_level,
    stusps,
    name,
    namelsad,
    short_name,
    is_cdp,
    aland,
    cell_geoid,
    rule
  )

# A place cell shows its short_name. A municipality-level subdivision
# (a town in New England, a city anywhere else) shows its name unless
# two in the state share it; any other subdivision or remainder, and a county
# cell, shows its namelsad.
cell_short_names <-
  cells |>
  st_drop_geometry() |>
  left_join(
    xwalk |>
      filter(geo_level == "place") |>
      distinct(geoid, place_short_name = short_name),
    by = "geoid"
  ) |>
  mutate(
    municipality = geo_level == "county_subdivision" &
      (str_ends(namelsad, " city") |
        (stusps %in% new_england & str_ends(namelsad, " town")))
  ) |>
  mutate(
    # in case this happens in future
    clash = municipality & sum(municipality) > 1,
    .by = c(stusps, name)
  ) |>
  transmute(
    geoid,
    short_name = case_when(
      geo_level == "place" ~ coalesce(place_short_name, namelsad),
      municipality & !clash ~ name,
      TRUE ~ namelsad
    )
  )

cells <-
  cells |>
  left_join(cell_short_names, by = "geoid") |>
  relocate(short_name, .after = namelsad)

# A place cell's county holds most of its 2020 population (land area where it
# has none), by the block table; a subdivision cell's is its own. Each block
# belongs to its place if the place is a cell, otherwise to its subdivision's
# cell.
block_cells <-
  blocks |>
  left_join(
    xwalk |>
      filter(
        geo_level == "place",
        cell_geoid == geoid | rule == "merged into consolidated government"
      ) |>
      select(place_geoid = geoid, place_cell = cell_geoid),
    by = "place_geoid"
  ) |>
  left_join(
    xwalk |>
      filter(geo_level == "county_subdivision") |>
      select(county_subdivision_geoid = geoid, subdivision_cell = cell_geoid),
    by = "county_subdivision_geoid"
  ) |>
  transmute(
    place_geoid,
    county_subdivision_geoid,
    geoid = coalesce(place_cell, subdivision_cell),
    county_geoid,
    pop20,
    aland
  )

place_county <-
  block_cells |>
  semi_join(
    cells |> st_drop_geometry() |> filter(is.na(county_geoid)),
    by = "geoid"
  ) |>
  summarise(
    pop = sum(pop20),
    aland = sum(aland),
    .by = c(geoid, county_geoid)
  ) |>
  mutate(
    county_share = if (sum(pop) > 0) pop / sum(pop) else aland / sum(aland),
    .by = geoid
  ) |>
  slice_max(county_share, n = 1, by = geoid, with_ties = FALSE) |>
  select(geoid, place_county_geoid = county_geoid, county_share)

# a place cell smaller than any block takes the county holding most of its area
area_county <-
  cells |>
  filter(is.na(county_geoid)) |>
  anti_join(place_county, by = "geoid") |>
  select(geoid) |>
  st_intersection(counties |> select(place_county_geoid = geoid)) |>
  suppressWarnings() |>
  mutate(area_m2 = geod_area(geometry)) |>
  st_drop_geometry() |>
  mutate(county_share = area_m2 / sum(area_m2), .by = geoid) |>
  slice_max(county_share, n = 1, by = geoid, with_ties = FALSE) |>
  select(geoid, place_county_geoid, county_share)

cells <-
  cells |>
  left_join(bind_rows(place_county, area_county), by = "geoid") |>
  mutate(
    county_share = if_else(is.na(county_geoid), county_share, 1),
    county_geoid = coalesce(county_geoid, place_county_geoid)
  ) |>
  select(-place_county_geoid) |>
  relocate(county_share, .after = county_geoid)

stopifnot(!anyNA(cells$county_geoid), !anyNA(cells$county_share))
print(area_county)

# The share of each unit's 2020 residents in its cell (cell_share) and in its
# cell's county (county_share). Land area is used for units with no residents.
unit_shares <-
  block_cells |>
  tidyr::pivot_longer(
    c(place_geoid, county_subdivision_geoid),
    names_to = NULL,
    values_to = "unit",
    values_drop_na = TRUE
  ) |>
  summarise(
    pop = sum(pop20),
    aland = sum(aland),
    .by = c(unit, geoid, county_geoid)
  ) |>
  mutate(
    has_residents = sum(pop) > 0,
    weight = if (sum(pop) > 0) as.numeric(pop) else as.numeric(aland),
    .by = unit
  ) |>
  mutate(cell_weight = sum(weight), .by = c(unit, geoid)) |>
  left_join(xwalk |> select(unit = geoid, cell_geoid), by = "unit") |>
  left_join(
    cells |>
      st_drop_geometry() |>
      select(cell_geoid = geoid, cell_county = county_geoid),
    by = "cell_geoid"
  ) |>
  summarise(
    cell_share = sum(weight[which(geoid == cell_geoid)]) / sum(weight),
    county_share = sum(weight[which(county_geoid == cell_county)]) /
      sum(weight),
    top_cell_share = max(cell_weight) / sum(weight),
    has_residents = first(has_residents),
    .by = unit
  )

# A unit with no blocks, or whose blocks have no residents and no land, takes
# the share of its polygon's area that is inside its cell.
area_cell_shares <-
  bind_rows(select(places, geoid), select(county_subdivisions, geoid)) |>
  inner_join(
    xwalk |>
      filter(!is.na(cell_geoid)) |>
      anti_join(
        unit_shares |> filter(is.finite(cell_share)),
        by = c("geoid" = "unit")
      ) |>
      select(geoid, cell_geoid),
    by = "geoid"
  ) |>
  mutate(unit_m2 = geod_area(geometry)) |>
  st_intersection(cells |> select(in_cell = geoid)) |>
  suppressWarnings() |>
  filter(in_cell == cell_geoid) |>
  st_make_valid() |>
  mutate(area_cell_share = pmin(geod_area(geometry) / unit_m2, 1)) |>
  st_drop_geometry() |>
  select(geoid, area_cell_share)

xwalk <-
  xwalk |>
  left_join(
    unit_shares |> select(unit, cell_share, county_share),
    by = c("geoid" = "unit")
  ) |>
  left_join(area_cell_shares, by = "geoid") |>
  left_join(
    cells |>
      st_drop_geometry() |>
      select(
        cell_geoid = geoid,
        cell_level = geo_level,
        cell_type,
        cell_namelsad = namelsad,
        cell_short_name = short_name,
        cell_county = county_geoid,
        cell_county_share = county_share
      ),
    by = "cell_geoid"
  ) |>
  mutate(
    cell_share = case_when(
      is.na(cell_geoid) ~ NA_real_,
      geo_level != "county_subdivision" & cell_geoid == geoid ~ 1,
      is.finite(cell_share) ~ cell_share,
      TRUE ~ area_cell_share
    ),
    county_share = case_when(
      is.na(cell_geoid) ~ NA_real_,
      geo_level == "county" ~ 1,
      is.finite(county_share) ~ county_share,
      # a place cell with no blocks: its polygon's area share
      geo_level == "place" & cell_geoid == geoid ~ cell_county_share,
      # a subdivision with no blocks, or none with residents or land: it lies
      # in one county
      geo_level == "county_subdivision" ~
        as.numeric(str_sub(geoid, 1, 5) == cell_county)
    )
  ) |>
  select(-cell_county, -cell_county_share, -area_cell_share) |>
  relocate(cell_share, county_share, .after = cell_geoid) |>
  arrange(stusps, geo_level, geoid)

stopifnot(
  !anyDuplicated(xwalk$geoid),
  "the xwalk is not every place, subdivision and county cell" = setequal(
    xwalk$geoid,
    c(places$geoid, county_subdivisions$geoid, county_cells$geoid)
  ),
  "a cell_geoid names no cell" = all(
    is.na(xwalk$cell_geoid) == is.na(xwalk$cell_level)
  ),
  "a cell is no geoid's cell" = all(cells$geoid %in% xwalk$cell_geoid),
  "a cell is not its own cell" = with(
    filter(xwalk, geoid %in% cells$geoid),
    all(cell_geoid == geoid)
  ),
  "cell_geoid missing without a 'no cell' rule" = all(
    is.na(xwalk$cell_geoid) == str_starts(xwalk$rule, "no cell")
  ),
  "cell_share or county_share is outside 0 to 1" = all(
    (between(xwalk$cell_share, 0, 1) | is.na(xwalk$cell_share)) &
      (between(xwalk$county_share, 0, 1) | is.na(xwalk$county_share))
  ),
  "a fold candidate is a cell without being a kept place" = setequal(
    xwalk |>
      semi_join(st_drop_geometry(fold_candidates), by = "geoid") |>
      filter(rule == "cell") |>
      pull(geoid),
    kept_places$geoid
  ),
  "a geoid with a cell has no cell_share or county_share" = !anyNA(
    xwalk[!is.na(xwalk$cell_geoid), c("cell_share", "county_share")]
  ),
  # gnis-places-county-subdivisions.R finds a place's blocks by cell_level
  "a place's cell is a place without it being a cell or a consolidated merge" = with(
    filter(xwalk, geo_level == "place", !is.na(cell_geoid)),
    all(
      (cell_level == "place") ==
        (cell_geoid == geoid | rule == "merged into consolidated government")
    )
  ),
  "Branford Center or Cross Village CDP does not fold, or Hampton Beach CDP does" = identical(
    xwalk |>
      filter(geoid %in% c("0907345", "2618880", "3333140")) |>
      arrange(geoid) |>
      pull(cell_namelsad),
    c("Branford town", "Cross Village township", "Hampton Beach CDP")
  ),
  "a place has no cell without having chosen a subdivision" = all(
    xwalk$geoid[xwalk$geo_level == "place" & is.na(xwalk$cell_geoid)] %in%
      fold_choice$geoid
  ),
  "a folded place with blocks has no cell_share" = xwalk |>
    filter(geo_level == "place", str_starts(rule, "folded")) |>
    semi_join(unit_shares, by = c("geoid" = "unit")) |>
    pull(cell_share) |>
    anyNA() |>
    isFALSE(),
  "a folded place is not in the cell holding the largest share of its residents" = xwalk |>
    filter(geo_level == "place", str_starts(rule, "folded")) |>
    inner_join(
      unit_shares |>
        filter(has_residents) |>
        select(geoid = unit, top_cell_share),
      by = "geoid"
    ) |>
    summarise(ok = all(abs(cell_share - top_cell_share) < 1e-12)) |>
    pull(ok),
  "an island-territory geoid has no cell" = !anyNA(
    xwalk$cell_geoid[xwalk$stusps %in% always_fold_states]
  ),
  "an island-territory cell is not a county or a Guam municipality" = all(
    (xwalk$cell_level == if_else(
      xwalk$stusps == "GU",
      "county_subdivision",
      "county"
    ))[xwalk$stusps %in% always_fold_states]
  )
)

stopifnot(
  !anyNA(cells$geoid),
  !any(st_is_empty(cells)),
  all(st_is_valid(cells)),
  st_crs(cells) == st_crs(4326),
  "a cell geoid is not a 5-digit county, 7-digit place or 10-digit subdivision" = all(
    nchar(cells$geoid) ==
      case_when(
        cells$geo_level == "county" ~ 5L,
        cells$geo_level == "place" ~ 7L,
        TRUE ~ 10L
      )
  ),
  "a cell's county is not in counties-sf" = all(
    cells$county_geoid %in% counties$geoid
  )
)

# The cells must tile every state
states <- st_read("data/states-sf.parquet", quiet = TRUE)

coverage <-
  cells |>
  group_by(stusps) |>
  summarize(
    cells_m2 = sum(geod_area(geometry)),
    covered = st_union(geometry)
  ) |>
  as_tibble() |>
  inner_join(
    states |> as_tibble() |> select(stusps, state = geometry),
    by = "stusps"
  ) |>
  mutate(
    state_m2 = geod_area(state),
    covered_m2 = geod_area(covered),
    gap_m2 = s2::s2_area(s2::s2_difference(st_as_s2(state), st_as_s2(covered))),
    overlap_m2 = cells_m2 - covered_m2,
    outside_m2 = covered_m2 - (state_m2 - gap_m2),
    gap_m2 = gap_m2 - coalesce(known_holes_m2[stusps], 0)
  ) |>
  select(-covered, -state)

# the dropped slivers: 1.4 km2 in 14 states
print(filter(coverage, gap_m2 > overlap_max_m2))

stopifnot(
  "a state has no cells" = all(state_codes %in% coverage$stusps),
  "cells leave part of a state uncovered" = all(coverage$gap_m2 <= gap_max_m2),
  "cells reach outside a state" = all(coverage$outside_m2 <= overlap_max_m2),
  "cells overlap" = all(abs(coverage$overlap_m2) <= overlap_max_m2)
)

print(count(as_tibble(cells), geo_level))
print(count(xwalk, geo_level, rule))
print(count(as_tibble(cells), cell_type))

sf::st_write(
  cells,
  dsn = "data/places-county-subdivisions-sf.parquet",
  driver = "Parquet",
  layer_options = "USE_PARQUET_GEO_TYPES=ONLY",
  delete_dsn = file.exists("data/places-county-subdivisions-sf.parquet"),
  quiet = TRUE
)
arrow::write_parquet(xwalk, "data/places-county-subdivisions-xwalk.parquet")
