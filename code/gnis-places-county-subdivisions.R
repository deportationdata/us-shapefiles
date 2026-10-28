#!/usr/bin/env Rscript
# Each GNIS populated place's cell in the places-county-subdivisions partition,
# found in three tiers and recorded in `match`:
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
  st_join(cell_attrs, join = st_within, left = TRUE) |>
  mutate(match = if_else(is.na(cell_geoid), NA_character_, "cell"))

# a point in two cells means the partition overlaps or the geometry engine
# differs from the build: fail, do not pick
stopifnot(!anyDuplicated(inside$feature_id))

unmatched <-
  inside |>
  filter(is.na(cell_geoid)) |>
  select(feature_id, stusps, name)

# ---- tier 2: inside the unclipped TIGER/Line place or subdivision -----------
# a state's TIGER/Line layer
tiger <- function(fun, state) {
  fun(
    pull(state, stusps),
    cb = FALSE,
    year = geo_vintage,
    progress_bar = FALSE
  ) |>
    st_transform(4326)
}

# Each point's TIGER/Line place and subdivision in its state, mapped to their
# cells; a point on a TIGER edge is in two, take the first. Subdivision code
# 00000 is TIGER's water placeholder.
by_tiger <-
  unmatched |>
  group_by(stusps) |>
  group_modify(\(pts, state) {
    pts |>
      st_join(tiger(tigris::places, state) |> select(tl_place = GEOID)) |>
      slice_min(tl_place, n = 1, by = feature_id, with_ties = FALSE) |>
      st_join(
        tiger(tigris::county_subdivisions, state) |>
          select(tl_county_subdivision = GEOID)
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
    tl_water = str_sub(tl_county_subdivision, 6, 10) == "00000"
  ) |>
  select(-place_cell, -county_subdivision_cell)

# ---- tier 3: nearest cell for points TIGER puts in water --------------------
water <- unmatched |> semi_join(by_tiger |> filter(tl_water), by = "feature_id")

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
  st_drop_geometry()
sf_use_s2(FALSE)

fallback <-
  by_tiger |>
  left_join(nearest, by = c("feature_id", "stusps", "name")) |>
  mutate(
    use_nearest = coalesce(
      is.na(cell_geoid) & tl_water & dist_m <= nearest_max_m,
      FALSE
    ),
    cell_geoid = if_else(use_nearest, near_geoid, cell_geoid),
    match = if_else(use_nearest, "nearest", match)
  ) |>
  select(feature_id, stusps, name, cell_geoid, match) |>
  left_join(st_drop_geometry(cell_attrs), by = "cell_geoid")

xwalk <-
  bind_rows(
    inside |> st_drop_geometry() |> filter(!is.na(cell_geoid)),
    fallback
  ) |>
  as_tibble() |>
  select(
    feature_id,
    stusps,
    name,
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
