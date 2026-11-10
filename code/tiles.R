#!/usr/bin/env Rscript
# PMTiles of each polygon level, cut by tippecanoe (brew install tippecanoe)
# from data/ and uploaded to R2 by .github/workflows/build-tiles.yml.

source("code/utils.R")

OUT_DIR <- "tiles"
MIN_ZOOM <- 2

# `cols` ride the tiles as string properties, geoid as the feature id. With
# `pixel_rule`, a feature enters at the zoom where it first covers a pixel.
LEVELS <- list(
  nationwide = list(
    file = "nationwide-sf.parquet",
    cols = c("geoid", "name"),
    maxzoom = 8
  ),
  countries = list(
    file = "countries-sf.parquet",
    cols = c("geoid", "name"),
    maxzoom = 10
  ),
  states = list(
    file = "states-sf.parquet",
    cols = c("geoid", "stusps", "name"),
    maxzoom = 10
  ),
  counties = list(
    file = "counties-sf.parquet",
    cols = c("geoid", "stusps", "name"),
    maxzoom = 10
  ),
  cbsas = list(
    file = "cbsas-sf.parquet",
    cols = c("geoid", "name", "lsad"),
    maxzoom = 10
  ),
  csas = list(
    file = "csas-sf.parquet",
    cols = c("geoid", "name"),
    maxzoom = 10
  ),
  metro_divisions = list(
    file = "metro-divisions-sf.parquet",
    cols = c("geoid", "name", "lsad"),
    maxzoom = 10
  ),
  places = list(
    file = "places-sf.parquet",
    cols = c("geoid", "stusps", "name"),
    maxzoom = 12,
    pixel_rule = TRUE
  ),
  cells = list(
    # Northeast tiles at z4-z5 reach ~0.93 MB; the 500 KB default drops a third
    file = "places-county-subdivisions-sf.parquet",
    cols = c("geoid", "short_name", "name"),
    maxzoom = 12,
    pixel_rule = TRUE,
    max_bytes = 1e6
  )
)

# The zoom at which a feature first covers a square CSS pixel: a MapLibre tile
# is 512 px wide, so a pixel spans 40075 km * cos(lat) / (512 * 2^z).
pixel_minzoom <- function(x, maxzoom) {
  area_km2 <- as.numeric(st_area(x)) / 1e6
  centroid <- st_centroid(st_geometry(x), of_largest_polygon = TRUE)
  lat <- st_coordinates(centroid)[, 2]
  z <- ceiling(log2(40075.016 * cos(lat * pi / 180) / (512 * sqrt(area_km2))))
  as.integer(pmin(pmax(z, MIN_ZOOM), maxzoom))
}

# tippecanoe can't read minzoom from a property, but its -j filter can gate on
# `$zoom` per value, then drop the property (-x would drop it before the gate).
zoom_filter <- function(minzoom) {
  gates <- glue(
    '["all",[">=","$zoom",{z}],["==","minzoom",{z}]]',
    z = sort(unique(minzoom))
  )
  glue(
    '{{"*":["all",["any",{str_flatten_comma(gates)}],',
    '["attribute-filter","minzoom",false]]}}'
  )
}

# Oversize tiles drop their smallest features rather than merge neighbours
# under one id, which a map keyed on geoid would mislabel.
run_tippecanoe <- function(input, out, level, spec) {
  args <- c(
    "-o",
    out,
    "-l",
    level,
    glue("-Z{MIN_ZOOM}"),
    glue("-z{spec$maxzoom}"),
    "--no-simplification-of-shared-nodes",
    "--drop-smallest-as-needed",
    if (isTRUE(spec$pixel_rule)) c("-j", shQuote(zoom_filter(input$minzoom))),
    if (!is.null(spec$max_bytes)) sprintf("-M%d", spec$max_bytes),
    "-q",
    input$path
  )
  unlink(out)
  stopifnot(system2("tippecanoe", args) == 0)
}

# Read back: the layer, every feature at maxzoom (tile splits duplicate, so
# >=), the pixel tier at a national zoom, and the properties a map keys on.
check_tiles <- function(out, level, spec, x) {
  features_at <- function(z) {
    lay <- st_layers(out, options = glue("ZOOM_LEVEL={z}"))
    stopifnot(identical(lay$name, level))
    lay$features
  }
  stopifnot(features_at(spec$maxzoom) >= nrow(x))
  if (isTRUE(spec$pixel_rule)) {
    z <- MIN_ZOOM + 2
    n <- sum(x$minzoom <= z)
    stopifnot(between(features_at(z), n * 5 / 6, n * 3))
  }
  probe <- read_sf(
    out,
    query = glue("SELECT * FROM {level} LIMIT 5"),
    options = glue("ZOOM_LEVEL={spec$maxzoom}"),
    quiet = TRUE
  )
  stopifnot(all(spec$cols %in% names(probe)))
}

stopifnot("tippecanoe is required" = nzchar(Sys.which("tippecanoe")))
levels <- commandArgs(trailingOnly = TRUE)
if (length(levels) == 0) {
  levels <- names(LEVELS)
}
stopifnot(levels %in% names(LEVELS))
dir.create(OUT_DIR, showWarnings = FALSE)

for (level in levels) {
  spec <- LEVELS[[level]]
  x <- st_read(file.path("data", spec$file), quiet = TRUE) |>
    select(all_of(spec$cols)) |>
    mutate(across(all_of(spec$cols), as.character))
  stopifnot(
    !anyDuplicated(x$geoid),
    !anyNA(x$geoid),
    !any(st_is_empty(x)),
    all(abs(st_bbox(x)) <= c(180, 90, 180, 90))
  )
  if (isTRUE(spec$pixel_rule)) {
    x$minzoom <- pixel_minzoom(x, spec$maxzoom)
  }
  input <- list(
    path = file.path(tempdir(), glue("{level}.geojsons")),
    minzoom = x$minzoom
  )
  unlink(input$path)
  st_write(x, input$path, driver = "GeoJSONSeq", quiet = TRUE)

  out <- file.path(OUT_DIR, glue("{level}.pmtiles"))
  run_tippecanoe(input, out, level, spec)
  check_tiles(out, level, spec, x)

  tiers <- ""
  if (isTRUE(spec$pixel_rule)) {
    tab <- table(x$minzoom)
    tiers <- glue(
      " (entering at {str_flatten(glue('z{names(tab)}: {tab}'), ', ')})"
    )
  }
  message(glue(
    "wrote {out}: {round(file.size(out) / 1e6, 1)} MB, {nrow(x)} features{tiers}"
  ))
}
