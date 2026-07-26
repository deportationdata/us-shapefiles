# Shared helpers for the code/*.R build scripts. Each script builds ONE
# geography as an sf object — attributes and full-resolution geometry
# together — and publishes it twice:
#
#   data/<level>-sf.parquet   GeoParquet, sfarrow::st_write_parquet()
#                             (sf/sfarrow, geopandas; DuckDB reads it as
#                             WKB with enable_geoparquet_conversion off)
#   data/<level>-shp.zip      zipped Esri shapefile, st_write() + zip
#
# Conventions every level shares:
#   - the PRIMARY geometry column is named `geometry`, WGS 84 (EPSG:4326),
#     at the source's full resolution (consumers that tile these files
#     simplify per zoom themselves — nothing here may pre-simplify)
#   - a level needing a second version of its geometry carries it as an
#     ADDITIONAL geometry column alongside (e.g. `geometry_point`) — one
#     file per geography, never a second file (the shapefile export
#     carries only the primary column; shapefiles are single-geometry)
#
# Scripts run from the repo root:  Rscript code/<level>.R

library(sf)
library(dplyr)
library(readr)
library(stringr)

TERRITORY_FIPS <- c("60", "66", "69", "78") # AS, GU, MP, VI

# Census cartographic-boundary shapefile -> sf, download cached in
# tempdir() so scripts reading the same zip share one fetch per session.
# `name` is the GENZ basename, e.g. "cb_2024_us_state_500k".
read_cb <- function(name, year) {
  url <- sprintf("https://www2.census.gov/geo/tiger/GENZ%d/shp/%s.zip",
                 year, name)
  zip <- file.path(tempdir(), basename(url))
  if (!file.exists(zip)) download.file(url, zip, mode = "wb", quiet = TRUE)
  shp_dir <- file.path(tempdir(), name)
  if (!dir.exists(shp_dir)) unzip(zip, exdir = shp_dir)
  read_sf(shp_dir)
}

# Geography join-key normalizer — the SAME definition the deportationdata
# apps apply to data values at runtime, so name-keyed joins against these
# files cannot drift. Deletes non-ASCII bytes outright (not transliterate:
# the published EOIR data carries U+FFFD where diacritics were corrupted
# upstream — "A�asco Municipio" — so deleting the diacritic character on
# both sides is the only transform that matches; iconv //TRANSLIT is also
# locale-dependent). Then uppercases and strips punctuation/whitespace so
# title-cased variants ("Baltimore City", "Dekalb", "Debaca") seen in
# older EOIR vintages still match. chartr, not toupper(): base toupper is
# LC_CTYPE-dependent (a tr_TR locale uppercases "i" to the non-ASCII "İ",
# which the gsub would then delete), while chartr on the post-iconv ASCII
# input is exact in every locale.
norm_geo_key <- function(x) {
  x <- iconv(x, from = "UTF-8", to = "ASCII", sub = "")
  x <- chartr("abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ", x)
  gsub("[^A-Z0-9]", "", x)
}

# Zipped-shapefile twin of each script's st_write_parquet() call: stage
# the shapefile parts in tempdir() and zip them flat into data/.
write_shp_zip <- function(x, level) {
  shp_dir <- file.path(tempdir(), paste0(level, "-shp"))
  unlink(shp_dir, recursive = TRUE)
  dir.create(shp_dir)
  st_write(x, file.path(shp_dir, paste0(level, ".shp")),
           layer_options = "ENCODING=UTF-8", quiet = TRUE)
  zip::zip(file.path(normalizePath("data"), paste0(level, "-shp.zip")),
           files = list.files(shp_dir), root = shp_dir)
}
