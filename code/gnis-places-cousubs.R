#!/usr/bin/env Rscript
# Each GNIS populated place's cell in the places-cousubs partition; `match`
# records how it was found (cell, tiger, nearest, NA): see README.

source("code/utils.R")

nearest_max_m <- 500

# the partition was built planar; join the same way
sf_use_s2(FALSE)

gnis <- st_read("data/gnis-populated-places-sf.parquet", quiet = TRUE)
cells <- st_read("data/places-cousubs-sf.parquet", quiet = TRUE)
geoid_cell <- arrow::read_parquet("data/places-cousubs-xwalk.parquet") |>
  select(geoid, cell_geoid)

cell_cols <- cells |>
  select(cell_geoid = geoid, cell_stusps = stusps, cell_level = geo_level, cell_namelsad = namelsad)

inside <-
  gnis |>
  select(feature_id, stusps, name) |>
  st_join(cell_cols, join = st_within, left = TRUE) |>
  mutate(match = if_else(is.na(cell_geoid), NA_character_, "cell"))

# a point in two cells means the partition overlaps or the geometry engine
# differs from the build: fail rather than pick
stopifnot(!anyDuplicated(inside$feature_id))

# first hit per point (a point on a TIGER edge is legitimately in both)
first_hit <- function(pts, polys, geoid) {
  h <- st_intersects(pts, polys)
  sapply(h, \(i) if (length(i)) min(geoid[i]) else NA_character_)
}

# Points off the generalized shoreline: locate them in the unclipped TIGER/Line
# place or cousub and map that to its cell.
miss <- inside |> filter(is.na(cell_geoid)) |> select(feature_id, stusps, name)
tl <- lapply(unique(miss$stusps), \(s) {
  pts <- miss |> filter(stusps == s)
  pl <- tryCatch(
    tigris::places(s, cb = FALSE, year = GEO_VINTAGE, progress_bar = FALSE) |> st_transform(4326),
    error = \(e) NULL
  )
  cs <- tigris::county_subdivisions(s, cb = FALSE, year = GEO_VINTAGE, progress_bar = FALSE) |>
    st_transform(4326)
  st_drop_geometry(pts) |>
    mutate(
      tl_place = if (is.null(pl)) NA_character_ else first_hit(pts, pl, pl$GEOID),
      tl_cousub = first_hit(pts, cs, cs$GEOID)
    )
}) |>
  bind_rows() |>
  mutate(
    cell_geoid = coalesce(
      geoid_cell$cell_geoid[match(tl_place, geoid_cell$geoid)],
      geoid_cell$cell_geoid[match(tl_cousub, geoid_cell$geoid)]
    ),
    match = if_else(is.na(cell_geoid), NA_character_, "tiger"),
    tl_water = str_sub(tl_cousub, 6, 10) == "00000"
  )

# Points TIGER puts in water: the nearest cell, if within nearest_max_m.
sf_use_s2(TRUE)
near <- lapply(split(miss, miss$stusps), \(pts) {
  cs <- cells |> filter(stusps == pts$stusps[1])
  i <- st_nearest_feature(pts, cs)
  st_drop_geometry(pts) |>
    mutate(
      near_geoid = cs$geoid[i],
      dist_m = as.numeric(st_distance(pts, cs[i, ], by_element = TRUE))
    )
}) |>
  bind_rows()
sf_use_s2(FALSE)

fallback <-
  tl |>
  left_join(near, by = c("feature_id", "stusps", "name")) |>
  mutate(
    match = case_when(
      !is.na(cell_geoid) ~ match,
      tl_water & dist_m <= nearest_max_m ~ "nearest",
      TRUE ~ NA_character_
    ),
    cell_geoid = if_else(match == "nearest", near_geoid, cell_geoid, missing = cell_geoid)
  ) |>
  select(feature_id, stusps, name, cell_geoid, match) |>
  left_join(st_drop_geometry(cell_cols), by = "cell_geoid")

xwalk <-
  bind_rows(
    inside |> st_drop_geometry() |> filter(!is.na(cell_geoid)),
    fallback
  ) |>
  as_tibble() |>
  select(feature_id, stusps, name, cell_geoid, cell_stusps, cell_level, cell_namelsad, match) |>
  arrange(stusps, name, feature_id)

stopifnot(
  !anyDuplicated(xwalk$feature_id),
  nrow(xwalk) == nrow(gnis),
  all(is.na(xwalk$cell_geoid) | xwalk$cell_geoid %in% cells$geoid),
  all(is.na(xwalk$cell_geoid) == is.na(xwalk$match))
)

print(count(xwalk, match, cell_level))

arrow::write_parquet(xwalk, "data/gnis-places-cousubs-xwalk.parquet")
