#!/usr/bin/env Rscript
# Non-overlapping partition into places and county subdivisions (Census
# summary level 070 with places kept whole), plus a geoid -> cell crosswalk.
# Town states: cousubs are cells and places fold into the cousub holding
# >= fold_share of them. Elsewhere: places are cells (except NY CDPs, which
# fold like town-state places) plus each cousub's non-sliver remainder; a
# cousub with no remainder lifts into the place holding >= fold_share of it.
# Two exceptions make place cells where places would otherwise fold (town
# states, NY CDPs): a municipality split by a county line (its county pieces
# merged), and a place that folds into no single cousub (carved out, leaving
# remainders).

source("code/utils.R")
library(purrr)

sf_use_s2(FALSE)

town_states <- c("ME", "NH", "VT", "MA", "RI", "CT", "NJ", "PA")
cdp_fold_states <- c("NY")
sliver_m2 <- 10000
sliver_share <- 0.01
sliver_width_m <- 50
whole_share <- 0.99999
fold_share <- 0.95
# consolidated city-county governments carry one of these LSAD codes; the
# "(balance)" and "Urban " name tests catch Indianapolis and Urban Honolulu,
# which carry ordinary ones
consolidated_lsad <- c("00", "UG", "CG", "MG", "UC")
consolidated_re <- "\\(balance\\)|^Urban "

# Not data/places-sf.parquet: its same-name dedup drops needed polygons.
places <-
  tigris::places(state = NULL, cb = TRUE, year = 2020) |>
  transmute(
    geoid = GEOID,
    stusps = STUSPS,
    name = NAME,
    namelsad = NAMELSAD,
    lsad = LSAD,
    is_cdp = str_ends(NAMELSAD, "CDP"),
    county_geoid = NA_character_,
    aland = ALAND,
    geometry
  ) |>
  st_transform(4326) |>
  st_make_valid()

cousubs <-
  st_read("data/cousubs-sf.parquet", quiet = TRUE) |>
  filter(name != "County subdivisions not defined") |>
  st_make_valid()

geod_area <- function(g) {
  old <- sf_use_s2()
  sf_use_s2(TRUE)
  on.exit(sf_use_s2(old))
  as.numeric(st_area(g))
}

geod_perimeter <- function(g) {
  old <- sf_use_s2()
  sf_use_s2(TRUE)
  on.exit(sf_use_s2(old))
  out <- numeric(length(g))
  ok <- !st_is_empty(g)
  out[ok] <- as.numeric(st_length(st_cast(st_cast(g[ok], "MULTIPOLYGON"), "MULTILINESTRING")))
  out
}

diff_one <- function(g, u) {
  empty <- st_sfc(st_polygon(), crs = st_crs(g))
  d <- st_make_valid(st_difference(g, u))
  if (length(d) == 0 || all(st_is_empty(d))) {
    return(empty)
  }
  if (any(st_is(d, "GEOMETRYCOLLECTION"))) {
    d <- st_collection_extract(d, "POLYGON", warn = FALSE)
  }
  if (length(d) == 0) {
    return(empty)
  }
  st_sfc(st_union(d), crs = st_crs(g))
}

mostly_one <- function(x, y, y_geoid) {
  hits <- st_intersects(x, y)
  total <- geod_area(x)
  map_chr(seq_along(hits), \(i) {
    h <- hits[[i]]
    if (length(h) == 0) {
      return(NA_character_)
    }
    share <- map_dbl(h, \(j) {
      sum(geod_area(st_make_valid(suppressWarnings(st_intersection(x[i], y[j])))))
    }) / total[i]
    if (max(share) >= fold_share) y_geoid[h[which.max(share)]] else NA_character_
  })
}

place_cells <-
  places |>
  filter(
    !stusps %in% town_states,
    !(stusps %in% cdp_fold_states & is_cdp)
  )

# county pieces of one municipality share its place code
split_pieces <-
  cousubs |>
  as_tibble() |>
  filter(stusps %in% town_states) |>
  transmute(geoid, merged_geoid = paste0(str_sub(geoid, 1, 2), str_sub(geoid, 6, 10))) |>
  filter(merged_geoid %in% places$geoid) |>
  filter(n() > 1, .by = merged_geoid)

# a shared code must be the same municipality, not a collision
stopifnot(all(
  cousubs$name[match(split_pieces$geoid, cousubs$geoid)] ==
    places$name[match(split_pieces$merged_geoid, places$geoid)]
))

merged_cells <-
  cousubs |>
  inner_join(split_pieces, by = "geoid") |>
  group_by(geoid = merged_geoid, stusps) |>
  summarize(.groups = "drop") |>
  st_make_valid() |>
  left_join(places |> as_tibble() |> select(geoid, name, namelsad), by = "geoid") |>
  mutate(geo_level = "place", county_geoid = NA_character_)

# places fold into cousubs, with a split municipality's pieces as one unit
fold_units <- bind_rows(
  cousubs |> filter(!geoid %in% split_pieces$geoid) |> select(geoid, geometry),
  merged_cells |> select(geoid, geometry)
)

folded <- places |> filter(!geoid %in% c(place_cells$geoid, merged_cells$geoid))
folded_cell <- setNames(
  mostly_one(st_geometry(folded), st_geometry(fold_units), fold_units$geoid),
  folded$geoid
)

place_cells <- bind_rows(place_cells, folded |> filter(is.na(folded_cell[geoid])))

remainders <-
  map(unique(cousubs$stusps), \(s) {
    cs <- cousubs |> filter(stusps == s, !geoid %in% split_pieces$geoid)
    pl <- place_cells |> filter(stusps == s)
    hits <- st_intersects(cs, pl)
    geoms <- map(seq_len(nrow(cs)), \(i) {
      if (length(hits[[i]]) == 0) {
        return(st_geometry(cs)[i])
      }
      diff_one(st_geometry(cs)[i], st_union(st_geometry(pl)[hits[[i]]]))
    })
    st_set_geometry(cs, do.call(c, geoms)) |>
      mutate(
        full_m2 = geod_area(st_geometry(cs)),
        area_m2 = if_else(st_is_empty(geometry), 0, geod_area(geometry)),
        width_m = if_else(area_m2 > 0, 2 * area_m2 / geod_perimeter(geometry), 0),
        subtracted = area_m2 < whole_share * full_m2,
        sliver = area_m2 < sliver_m2 |
          (area_m2 < sliver_share * full_m2 & width_m < sliver_width_m)
      )
  }) |>
  bind_rows() |>
  filter(!sliver) |>
  mutate(
    geo_level = if_else(subtracted, "remainder", "cousub"),
    namelsad = if_else(subtracted, paste0(namelsad, " (remainder)"), namelsad)
  ) |>
  select(-subtracted, -area_m2, -full_m2, -width_m, -sliver)

cells <-
  bind_rows(
    place_cells |> mutate(geo_level = "place") |> select(-is_cdp, -lsad, -aland),
    merged_cells,
    remainders |> select(-lsad, -aland)
  ) |>
  select(geoid, stusps, name, namelsad, geo_level, county_geoid, geometry) |>
  arrange(stusps, geo_level, geoid)

stopifnot(!anyDuplicated(cells$geoid))

cousub_cell_geoids <- cells |> filter(geo_level != "place") |> pull(geoid)

place_rows <-
  places |>
  mutate(
    cell_geoid = case_when(
      geoid %in% cells$geoid ~ geoid,
      TRUE ~ unname(folded_cell[geoid])
    ),
    cell_geoid = if_else(
      !is.na(cell_geoid) & cell_geoid != geoid &
        !cell_geoid %in% c(cousub_cell_geoids, merged_cells$geoid),
      NA_character_,
      cell_geoid
    ),
    rule = case_when(
      cell_geoid == geoid ~ "cell",
      !is.na(cell_geoid) ~ "folded into subdivision",
      TRUE ~ "no cell: not mostly within one subdivision"
    )
  )

lifted <- cousubs |> filter(!geoid %in% cells$geoid)
lifted_cell <- setNames(
  mostly_one(st_geometry(lifted), st_geometry(place_cells), place_cells$geoid),
  lifted$geoid
)

cousub_rows <-
  cousubs |>
  mutate(
    cell_geoid = case_when(
      geoid %in% cells$geoid ~ geoid,
      geoid %in% split_pieces$geoid ~ split_pieces$merged_geoid[match(geoid, split_pieces$geoid)],
      TRUE ~ unname(lifted_cell[geoid])
    ),
    rule = case_when(
      cell_geoid == geoid ~ "cell",
      geoid %in% split_pieces$geoid ~ "merged across county line",
      !is.na(cell_geoid) ~ "lifted into place",
      TRUE ~ "no cell: covered by several places"
    )
  )

xwalk <-
  bind_rows(
    place_rows |> as_tibble() |> mutate(geo_level = "place") |>
      select(geoid, geo_level, stusps, name, namelsad, lsad, is_cdp, aland, cell_geoid, rule),
    cousub_rows |> as_tibble() |> mutate(geo_level = "cousub", is_cdp = FALSE) |>
      select(geoid, geo_level, stusps, name, namelsad, lsad, is_cdp, aland, cell_geoid, rule)
  ) |>
  left_join(
    cells |> as_tibble() |> select(cell_geoid = geoid, cell_level = geo_level, cell_namelsad = namelsad),
    by = "cell_geoid"
  ) |>
  mutate(
    common_name = if_else(
      geo_level == "place" &
        (lsad %in% consolidated_lsad | str_detect(namelsad, consolidated_re)),
      name |>
        str_remove("\\s*\\(balance\\)$") |>
        str_remove("^Urban ") |>
        str_remove("[-/,].*$") |>
        str_remove("\\s+(city|County.*)$"),
      name
    ),
    .after = namelsad
  ) |>
  select(-lsad) |>
  arrange(stusps, geo_level, geoid)

stopifnot(
  !anyDuplicated(xwalk$geoid),
  all(is.na(xwalk$cell_geoid) | xwalk$cell_geoid %in% cells$geoid)
)

print(count(as_tibble(cells), geo_level))
print(count(xwalk, geo_level, rule))

sf::st_write(cells, dsn = "data/places-cousubs-sf.parquet", driver = "Parquet", layer_options = "USE_PARQUET_GEO_TYPES=ONLY", delete_dsn = file.exists("data/places-cousubs-sf.parquet"), quiet = TRUE)
arrow::write_parquet(xwalk, "data/places-cousubs-xwalk.parquet")
