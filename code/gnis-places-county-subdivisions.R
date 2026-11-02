#!/usr/bin/env Rscript
# Each GNIS populated place's county (USGS's own, carried from the points
# file) and its cell in the places-county-subdivisions partition, found in
# three tiers and recorded in `match`:
#   cell     the point is inside a cell
#   tiger    it is off the generalized shoreline but inside the unclipped
#            TIGER/Line place or county subdivision, which maps to a cell
#   nearest  TIGER puts it in water; the nearest cell within nearest_max_m
#   NA       none of the above

source("code/utils.R")

nearest_max_m <- 500

# the partition was built planar; join the same way
sf_use_s2(FALSE)

gnis <- st_read("data/gnis-populated-places-sf.parquet", quiet = TRUE)
cells <- st_read("data/places-county-subdivisions-sf.parquet", quiet = TRUE)
geoid_cell <-
  arrow::read_parquet("data/places-county-subdivisions-xwalk.parquet") |>
  select(geoid, cell_geoid)

cell_attrs <-
  cells |>
  st_drop_geometry() |>
  select(
    cell_geoid = geoid,
    cell_stusps = stusps,
    cell_level = geo_level,
    cell_namelsad = namelsad
  )

# ---- tier 1: inside a cell --------------------------------------------------
inside <-
  gnis |>
  select(feature_id, stusps, name) |>
  st_join(cells |> select(cell_geoid = geoid), join = st_within, left = TRUE) |>
  mutate(match = if_else(is.na(cell_geoid), NA_character_, "cell"))

# a point in two cells means the partition overlaps
stopifnot(!anyDuplicated(inside$feature_id))

unmatched <-
  inside |>
  filter(is.na(cell_geoid)) |>
  select(feature_id, stusps, name)

# ---- tier 2: inside the unclipped TIGER/Line place or subdivision -----------
# Each point's TIGER/Line place and subdivision in its state, mapped to their
# cells; a point on a TIGER edge is in two, take the first. Subdivision code
# 00000 is TIGER's water placeholder.
by_tiger <-
  unmatched |>
  group_by(stusps) |>
  group_modify(\(pts, state) {
    pts |>
      st_join(
        tigris::places(
          pull(state, stusps),
          cb = FALSE,
          year = geo_vintage,
          progress_bar = FALSE
        ) |>
          st_transform(4326) |>
          select(tl_place = GEOID),
        join = st_intersects
      ) |>
      slice_min(tl_place, n = 1, by = feature_id, with_ties = FALSE) |>
      st_join(
        tigris::county_subdivisions(
          pull(state, stusps),
          cb = FALSE,
          year = geo_vintage,
          progress_bar = FALSE
        ) |>
          st_transform(4326) |>
          select(tl_county_subdivision = GEOID),
        join = st_intersects
      ) |>
      slice_min(
        tl_county_subdivision,
        n = 1,
        by = feature_id,
        with_ties = FALSE
      )
  }) |>
  ungroup() |>
  st_as_sf() |>
  st_drop_geometry() |>
  left_join(
    geoid_cell |> rename(tl_place = geoid, place_cell = cell_geoid),
    by = "tl_place"
  ) |>
  left_join(
    geoid_cell |>
      rename(
        tl_county_subdivision = geoid,
        county_subdivision_cell = cell_geoid
      ),
    by = "tl_county_subdivision"
  ) |>
  mutate(
    cell_geoid = coalesce(place_cell, county_subdivision_cell),
    match = if_else(is.na(cell_geoid), NA_character_, "tiger"),
    tl_water = coalesce(str_sub(tl_county_subdivision, 6, 10) == "00000", FALSE)
  )

# ---- tier 3: nearest cell for points TIGER puts in water --------------------
water <-
  unmatched |>
  semi_join(by_tiger |> filter(is.na(cell_geoid), tl_water), by = "feature_id")

# distances on the sphere, within the point's own state
sf_use_s2(TRUE)
nearest <-
  water |>
  group_by(stusps) |>
  group_modify(\(pts, state) {
    pts |>
      st_join(
        cells |>
          semi_join(state, by = "stusps") |>
          transmute(near_geoid = geoid, near_geometry = geometry),
        join = st_nearest_feature
      ) |>
      mutate(
        dist_m = as.numeric(st_distance(
          geometry,
          near_geometry,
          by_element = TRUE
        ))
      ) |>
      select(-near_geometry)
  }) |>
  ungroup() |>
  st_as_sf() |>
  st_drop_geometry() |>
  mutate(
    cell_geoid = if_else(dist_m <= nearest_max_m, near_geoid, NA_character_),
    match = if_else(is.na(cell_geoid), NA_character_, "nearest")
  )
sf_use_s2(FALSE)

# each tier's matches, plus whatever no tier placed
xwalk <-
  bind_rows(
    inside |> st_drop_geometry() |> filter(!is.na(cell_geoid)),
    by_tiger |> filter(!is.na(cell_geoid)),
    nearest,
    by_tiger |> filter(is.na(cell_geoid), !tl_water)
  ) |>
  as_tibble() |>
  left_join(cell_attrs, by = "cell_geoid") |>
  left_join(
    gnis |> st_drop_geometry() |> select(feature_id, county_geoid),
    by = "feature_id"
  ) |>
  select(
    feature_id,
    stusps,
    name,
    county_geoid,
    cell_geoid,
    cell_stusps,
    cell_level,
    cell_namelsad,
    match
  ) |>
  arrange(stusps, name, feature_id)

stopifnot(
  !anyDuplicated(xwalk$feature_id),
  nrow(xwalk) == nrow(gnis),
  all(is.na(xwalk$cell_geoid) | xwalk$cell_geoid %in% cells$geoid),
  all(is.na(xwalk$cell_geoid) == is.na(xwalk$match))
)

print(count(xwalk, match, cell_level))

arrow::write_parquet(
  xwalk,
  "data/gnis-places-county-subdivisions-xwalk.parquet"
)
