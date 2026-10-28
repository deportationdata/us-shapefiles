#!/usr/bin/env Rscript
# USGS GNIS populated places as points (feature_id, stusps, name, county_name),
# from the national Domestic Names text file pinned in inputs/.

source("code/utils.R")

# USGS only publishes a rolling current file, so the copy in inputs/ is pinned
# by its <pubdate>; bump gnis_version to update it.
gnis_url <- "https://prd-tnm.s3.amazonaws.com/StagedProducts/GeographicNames/DomesticNames/DomesticNames_National_Text.zip"
gnis_version <- "20260929"
gnis_zip <- str_c("inputs/DomesticNames_National_Text_", gnis_version, ".zip")

gnis_pubdate <- function(zip) {
  xml <- read_file(unz(zip, "DomesticNames_National_Text.xml"))
  str_match(xml, "<pubdate>(\\d{8})</pubdate>")[, 2]
}

if (!file.exists(gnis_zip)) {
  options(timeout = 1800) # the zip is a few hundred MB
  tmp <- tempfile(fileext = ".zip")
  download.file(gnis_url, tmp, mode = "wb", quiet = TRUE)
  if (gnis_pubdate(tmp) != gnis_version) {
    stop(
      "the current USGS file is dated ",
      gnis_pubdate(tmp),
      ", not gnis_version ",
      gnis_version
    )
  }
  file.copy(tmp, gnis_zip)
}
stopifnot(gnis_pubdate(gnis_zip) == gnis_version)

unzipped <- tempfile()
unzip(gnis_zip, exdir = unzipped)

# GNIS names states in full; state.name lines up with state.abb
state_lookup <- tibble(
  stusps = state_codes,
  state_name = c(
    state.name,
    "District of Columbia",
    "Puerto Rico",
    "Guam",
    "United States Virgin Islands",
    "Commonwealth of the Northern Mariana Islands",
    "American Samoa"
  )
)

# GNIS coordinate errors that put a place at sea, abroad or in the wrong town;
# each line cites the evidence for the corrected position
gnis_fixes <- tibble::tribble(
  ~feature_id , ~lat        , ~long        ,
  "1389333"   , -14.2706462 , -170.5695747 , # Utumea AS: longitude sign flipped; lands in Utumea East village (55 people, 2020 Census)
  "1940942"   ,  13.52103   ,  144.82259   , # Liguan Terrace GU: GNIS has it 9 km N at Ritidian Point; GeoNames/Mapcarta position, in Liguan CDP
  "1993166"   ,  18.0557995 ,  -66.7237713 , # Residencial Los Flamboyanes PR: longitude 1 deg E of Penuelas; matches the Google/Waze listing (18.0557, -66.7238)
  "1993276"   ,  18.0635737 ,  -66.7223967 , # Alturas de Peneulas PR: misspelt twin of 1993275 Alturas de Penuelas, given its position
  "1990498"   ,  18.1574587 ,  -66.7218409 , # Alturas de Adjuntas PR: twin of 1993165 Residencial Alturas de Adjuntas (AVP public housing), given its position
  "1613265"   ,  18.40772   ,  -67.13712   , # Vinet PR: at sea off Culebra; Sector Vinet is in Palmar barrio, Aguadilla; placed at Los Cerros Vinet (GeoNames) there
  "1376921"   ,  29.4354386 , -104.1929929 # Polvo TX: 84 m into the Rio Grande; El Polvo is Redford's original name (Handbook of Texas); moved to the Redford CDP bank
)

gnis_sf <-
  read_delim(
    list.files(
      unzipped,
      "DomesticNames_National.txt",
      recursive = TRUE,
      full.names = TRUE
    ),
    delim = "|",
    show_col_types = FALSE,
    col_types = cols(feature_id = col_character()),
    col_select = c(
      feature_id,
      feature_name,
      feature_class,
      state_name,
      county_name,
      prim_lat_dec,
      prim_long_dec
    )
  ) |>
  # 0/0 is GNIS's unknown location
  filter(
    feature_class == "Populated Place",
    !str_detect(feature_name, fixed("(historical)")),
    !is.na(prim_lat_dec),
    !is.na(prim_long_dec),
    !(prim_lat_dec == 0 & prim_long_dec == 0)
  ) |>
  inner_join(state_lookup, by = "state_name") |>
  transmute(
    feature_id,
    stusps,
    name = feature_name,
    county_name,
    lat = prim_lat_dec,
    long = prim_long_dec
  ) |>
  # a fix for a feature GNIS has since dropped is ignored
  rows_update(gnis_fixes, by = "feature_id", unmatched = "ignore") |>
  st_as_sf(coords = c("long", "lat"), crs = 4269) |> # GNIS coordinates are NAD83
  st_transform(4326) |>
  arrange(stusps, name, feature_id)

stopifnot(!anyDuplicated(gnis_sf$feature_id))

sf::st_write(
  gnis_sf,
  dsn = "data/gnis-populated-places-sf.parquet",
  driver = "Parquet",
  layer_options = "USE_PARQUET_GEO_TYPES=ONLY",
  delete_dsn = file.exists("data/gnis-populated-places-sf.parquet"),
  quiet = TRUE
)
