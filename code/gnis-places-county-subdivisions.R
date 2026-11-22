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
cell_xwalk <- arrow::read_parquet("data/places-county-subdivisions-xwalk.parquet")
geoid_cell <- cell_xwalk |> select(geoid, cell_geoid)

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
  select(feature_id, stusps, name, county_geoid) |>
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

# each later tier fills in what the one before left unmatched
xwalk <-
  inside |>
  st_drop_geometry() |>
  as_tibble() |>
  rows_patch(by_tiger |> select(feature_id, cell_geoid, match), by = "feature_id") |>
  rows_patch(nearest |> select(feature_id, cell_geoid, match), by = "feature_id") |>
  left_join(cell_attrs, by = "cell_geoid") |>
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

# ---- GNIS names on subdivision and county-remainder cells -------------------
# One row per such cell, written to its own file. Names are ordered by the 2020 residents nearest each point (each populated
# block goes to the cell's nearest point); that count is not a population.
names_cell_types <- c("subdivision", "county_remainder")
names_separator <- "; "

named_cells <-
  cells |>
  st_drop_geometry() |>
  filter(cell_type %in% names_cell_types) |>
  select(cell_geoid = geoid)

cell_points <-
  xwalk |>
  select(feature_id, name, cell_geoid) |>
  semi_join(named_cells, by = "cell_geoid")

stopifnot(!any(str_detect(cell_points$name, fixed(str_trim(names_separator)))))

# each block's cell: its place's when the place is a cell, else its
# subdivision's
block_points <-
  arrow::read_parquet(
    "data/blocks-xwalk.parquet",
    col_select = c("pop20", "lat", "lon", "place_geoid", "county_subdivision_geoid")
  ) |>
  filter(coalesce(pop20, 0L) > 0) |>
  left_join(
    cell_xwalk |>
      filter(geo_level == "place", cell_level == "place") |>
      select(place_geoid = geoid, place_cell = cell_geoid),
    by = "place_geoid"
  ) |>
  left_join(
    cell_xwalk |>
      filter(geo_level == "county_subdivision") |>
      select(county_subdivision_geoid = geoid, subdivision_cell = cell_geoid),
    by = "county_subdivision_geoid"
  ) |>
  transmute(cell_geoid = coalesce(place_cell, subdivision_cell), pop20, lat, lon) |>
  semi_join(cell_points, by = "cell_geoid")

points_by_cell <-
  gnis |>
  select(feature_id) |>
  inner_join(cell_points |> select(feature_id, cell_geoid), by = "feature_id")

# nearest on the sphere, as in tier 3
sf_use_s2(TRUE)
nearest_residents <-
  block_points |>
  st_as_sf(coords = c("lon", "lat"), crs = 4269) |> # Census points are NAD83
  st_transform(st_crs(gnis)) |>
  group_by(cell_geoid) |>
  group_modify(\(blocks, cell) {
    st_join(
      blocks,
      points_by_cell |> semi_join(cell, by = "cell_geoid") |> select(feature_id),
      join = st_nearest_feature
    )
  }) |>
  ungroup() |>
  count(cell_geoid, feature_id, wt = pop20, name = "nearest_pop20")
sf_use_s2(FALSE)

cell_names <-
  cell_points |>
  left_join(nearest_residents, by = c("cell_geoid", "feature_id")) |>
  summarise(
    nearest_pop20 = sum(nearest_pop20, na.rm = TRUE),
    .by = c(cell_geoid, name)
  ) |>
  arrange(cell_geoid, desc(nearest_pop20), name) |>
  summarise(
    gnis_names = str_c(name, collapse = names_separator),
    gnis_n = n(),
    .by = cell_geoid
  )

named_cell_names <-
  named_cells |>
  left_join(cell_names, by = "cell_geoid") |>
  mutate(gnis_n = coalesce(gnis_n, 0L)) |>
  arrange(cell_geoid)

stopifnot(!anyDuplicated(named_cell_names$cell_geoid))

print(count(named_cell_names, has_names = !is.na(gnis_names)))

arrow::write_parquet(
  named_cell_names,
  "data/gnis-places-county-subdivisions-names.parquet"
)
