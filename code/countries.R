#!/usr/bin/env Rscript
# Countries, dependencies and areas of special sovereignty (geoid, name,
# status) from the State Department's World Polygons (the LSIB polygons):
# from State's lists of Independent States and of Dependencies and
# Areas of Special Sovereignty.

source("code/utils.R")

# State overwrites WorldPolygons.zip in place with each release; the zip
# inside it is named by version.
wp_url <- "https://data.geodata.state.gov/WorldPolygons.zip"
wp_version <- "WorldPolygon_11_4_BETA_24Feb2025"
wp_layer <- "DoS_WP_11_4_G65"

cache <- path.expand(rappdirs::user_cache_dir("us-shapefiles"))
wp_gpkg <- file.path(cache, wp_version, "WorldPolygons11_4.gpkg")

if (!file.exists(wp_gpkg)) {
  options(timeout = 7200) # 2.4 GB
  zip <- tempfile(fileext = ".zip")
  download.file(wp_url, zip, mode = "wb", quiet = TRUE)
  inner <- unzip(
    zip,
    str_c("WorldPolygons/", wp_version, ".zip"),
    exdir = tempdir()
  )
  unzip(inner, str_c(wp_version, "/WorldPolygons11_4.gpkg"), exdir = cache)
  unlink(c(zip, inner))
}

# State's names have U+FFFD where diacritics were lost
name_fixes <- c(
  "C�te d�Ivoire" = "Côte d'Ivoire",
  "Cura�ao" = "Curaçao",
  "�$" = ""
)

sf_use_s2(FALSE)
countries_sf <-
  st_read(wp_gpkg, layer = wp_layer, quiet = TRUE) |>
  mutate(across(
    where(is.character),
    \(x) na_if(str_replace_all(str_trim(x), name_fixes), "")
  )) |>
  st_set_precision(1e7) |> # Antarctica overshoots 180 by 1e-13
  st_make_valid() |>
  # the unnamed polygon is the Caspian Sea; QX2/QX4 are slivers GENC has no
  # code for (DMZs, condominiums, No Man's Land)
  filter(!is.na(WP_Name), !GENC_3 %in% c("QX2", "QX4")) |>
  # a code can span several polygons (Spain and the Canaries, Sudan and the
  # Hala'ib Triangle, the Caribbean Netherlands, one dispute code over
  # several areas) - convert to one feature per code, named from State's list
  group_by(geoid = GENC_3) |>
  summarize(
    name = first(na.omit(c(DOS_Short, GENC_Short))),
    genc_name = first(na.omit(GENC_Short)),
    status = str_to_lower(word(first(na.omit(US_Recog)))),
    geometry = suppressMessages(st_union(geom)),
    .groups = "drop"
  ) |>
  # the French Southern islands share one State name
  group_by(name) |>
  mutate(name = if (n() > 1) genc_name else name) |>
  ungroup() |>
  select(geoid, name, status, geometry) |>
  st_cast("MULTIPOLYGON") |>
  arrange(geoid)

stopifnot(
  !anyNA(countries_sf$geoid),
  !anyDuplicated(countries_sf$geoid),
  !any(st_is_empty(countries_sf)),
  st_crs(countries_sf) == st_crs(4326),
  !anyDuplicated(countries_sf$name),
  !anyNA(countries_sf$name),
  !any(str_detect(countries_sf$name, "�")),
  all(st_is_valid(countries_sf))
)

sf::st_write(
  countries_sf,
  dsn = "data/countries-sf.parquet",
  driver = "Parquet",
  layer_options = "USE_PARQUET_GEO_TYPES=ONLY",
  delete_dsn = file.exists("data/countries-sf.parquet"),
  quiet = TRUE
)
