#!/usr/bin/env Rscript
# Non-overlapping partition of the country into cells built from places and
# county subdivisions, plus a geoid → cell crosswalk.
#   cell         a place, a county subdivision, or a subdivision's remainder
#                (what is left once its places are cut out)
#   fold         assign a place to the subdivision cell holding it
#   lift         assign a subdivision to the place cell covering it
#   merged cell  a town-state municipality split by a county line, rejoined
# Steps: merge split municipalities; fold town-state places and NY CDPs, those
# fitting no single subdivision become cells; cut place cells out of
# subdivisions, keeping remainders; crosswalk every geoid; short names.

source("code/utils.R")

sf_use_s2(FALSE)

# Town states: subdivisions are the cells and places fold into them; elsewhere
# places are cells and subdivisions keep remainders. NY CDPs fold too. In New
# England a town is a municipality, which matters for short names.
town_states <- c("ME", "NH", "VT", "MA", "RI", "CT", "NJ", "PA")
new_england <- c("ME", "NH", "VT", "MA", "RI", "CT")
cdp_fold_states <- "NY"

# A place folds into a subdivision holding >= fold_share of it; a subdivision
# keeping >= whole_share after cutting is untouched; a remainder under
# sliver_m2, or under sliver_share and narrower than sliver_width_m, is dropped.
fold_share <- 0.95
whole_share <- 0.99999
sliver_m2 <- 10000
sliver_share <- 0.01
sliver_width_m <- 50

places <-
  st_read("data/places-sf.parquet", quiet = TRUE) |>
  transmute(
    geoid,
    stusps,
    name,
    namelsad,
    short_name,
    is_cdp = str_ends(namelsad, "CDP"),
    county_geoid = NA_character_, # a place can span counties
    aland,
    geometry
  ) |>
  st_make_valid()

county_subdivisions <-
  st_read("data/county-subdivisions-sf.parquet", quiet = TRUE) |>
  st_make_valid()

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

merged_cells <-
  county_subdivisions |>
  inner_join(split_pieces, by = "geoid") |>
  group_by(geoid = merged_geoid, stusps) |>
  summarize(.groups = "drop") |>
  st_make_valid() |>
  left_join(
    places |> as_tibble() |> select(geoid, name, namelsad, short_name),
    by = "geoid"
  ) |>
  mutate(geo_level = "place", county_geoid = NA_character_)

unsplit <- county_subdivisions |> anti_join(split_pieces, by = "geoid")

# fold targets: subdivisions, with a split municipality's pieces as one
fold_units <- bind_rows(
  unsplit |> select(geoid, geometry),
  merged_cells |> select(geoid, geometry)
)

# A town-state place or NY CDP folds into the unit holding >= fold_share of
# it; one that fits no single unit becomes a cell, carved out of them.
fold_candidates <-
  places |>
  filter(stusps %in% town_states | (stusps %in% cdp_fold_states & is_cdp)) |>
  anti_join(st_drop_geometry(merged_cells), by = "geoid")

folded_cell <-
  fold_candidates |>
  mutate(whole_m2 = geod_area(geometry)) |>
  st_intersection(fold_units |> select(cell_geoid = geoid)) |>
  suppressWarnings() |>
  st_make_valid() |>
  mutate(share = geod_area(geometry) / whole_m2) |>
  st_drop_geometry() |>
  filter(share >= fold_share) |>
  slice_max(share, n = 1, by = geoid, with_ties = FALSE) |>
  select(geoid, cell_geoid)

# every place that neither merged nor folded is a cell
place_cells <-
  places |>
  anti_join(st_drop_geometry(merged_cells), by = "geoid") |>
  anti_join(folded_cell, by = "geoid")

# Each subdivision minus its state's place cells (cross-state neighbours only
# add noise); slivers dropped; one wholly inside places vanishes.
place_union <-
  place_cells |>
  group_by(stusps) |>
  summarize(.groups = "drop")

remainders <-
  unsplit |>
  mutate(full_m2 = geod_area(geometry)) |>
  group_by(stusps) |>
  group_modify(\(cs, state) {
    st_difference(cs, st_geometry(semi_join(place_union, state, by = "stusps")))
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

cells <-
  bind_rows(
    place_cells |> mutate(geo_level = "place"),
    merged_cells,
    remainders
  ) |>
  select(geoid, stusps, name, namelsad, geo_level, county_geoid, geometry) |>
  arrange(stusps, geo_level, geoid)

stopifnot(!anyDuplicated(cells$geoid))

is_cell <- cells |> st_drop_geometry() |> transmute(geoid, is_cell = TRUE)

# A place is its own cell, else folds into its target when that survived as a
# cell (a lifted subdivision is no longer there to fold into).
place_rows <-
  places |>
  left_join(is_cell, by = "geoid") |>
  left_join(
    folded_cell |>
      semi_join(is_cell, by = c("cell_geoid" = "geoid")) |>
      rename(folded_geoid = cell_geoid),
    by = "geoid"
  ) |>
  mutate(
    cell_geoid = if_else(coalesce(is_cell, FALSE), geoid, folded_geoid),
    rule = case_when(
      cell_geoid == geoid ~ "cell",
      !is.na(cell_geoid) ~ "folded into subdivision",
      TRUE ~ "no cell: not mostly within one subdivision"
    )
  ) |>
  select(-folded_geoid, -is_cell)

# A county subdivision with no remainder lifts into the place holding most of it
# (split pieces already have their merged cell).
lifted_cell <-
  unsplit |>
  anti_join(st_drop_geometry(cells), by = "geoid") |>
  mutate(whole_m2 = geod_area(geometry)) |>
  st_intersection(place_cells |> select(cell_geoid = geoid)) |>
  suppressWarnings() |>
  st_make_valid() |>
  mutate(share = geod_area(geometry) / whole_m2) |>
  st_drop_geometry() |>
  filter(share >= fold_share) |>
  slice_max(share, n = 1, by = geoid, with_ties = FALSE) |>
  select(geoid, cell_geoid)

county_subdivision_rows <-
  county_subdivisions |>
  left_join(split_pieces, by = "geoid") |>
  left_join(lifted_cell |> rename(lifted_geoid = cell_geoid), by = "geoid") |>
  left_join(is_cell, by = "geoid") |>
  mutate(
    cell_geoid = case_when(
      coalesce(is_cell, FALSE) ~ geoid,
      !is.na(merged_geoid) ~ merged_geoid,
      TRUE ~ lifted_geoid
    ),
    rule = case_when(
      cell_geoid == geoid ~ "cell",
      !is.na(merged_geoid) ~ "merged across county line",
      !is.na(cell_geoid) ~ "lifted into place",
      TRUE ~ "no cell: covered by several places"
    )
  ) |>
  select(-merged_geoid, -lifted_geoid, -is_cell)

xwalk <-
  bind_rows(
    place_rows |> mutate(geo_level = "place"),
    county_subdivision_rows |>
      mutate(geo_level = "county_subdivision", is_cdp = FALSE)
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

# A place cell shows its short_name. A municipality-level subdivision (a city
# anywhere, a town in New England) shows its name unless two in the state share
# it; any other subdivision or remainder shows its namelsad.
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

xwalk <-
  xwalk |>
  left_join(
    cells |>
      st_drop_geometry() |>
      select(
        cell_geoid = geoid,
        cell_level = geo_level,
        cell_namelsad = namelsad,
        cell_short_name = short_name
      ),
    by = "cell_geoid"
  ) |>
  arrange(stusps, geo_level, geoid)

stopifnot(
  !anyDuplicated(xwalk$geoid),
  "a cell_geoid names no cell" = all(
    is.na(xwalk$cell_geoid) == is.na(xwalk$cell_level)
  )
)

print(count(as_tibble(cells), geo_level))
print(count(xwalk, geo_level, rule))

sf::st_write(
  cells,
  dsn = "data/places-county-subdivisions-sf.parquet",
  driver = "Parquet",
  layer_options = "USE_PARQUET_GEO_TYPES=ONLY",
  delete_dsn = file.exists("data/places-county-subdivisions-sf.parquet"),
  quiet = TRUE
)
arrow::write_parquet(xwalk, "data/places-county-subdivisions-xwalk.parquet")
