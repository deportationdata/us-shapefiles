# Shared helpers for the code/*.R build scripts. Each script builds ONE
# geography as an sf object — attributes and full-resolution geometry
# together — and publishes it as data/<level>-sf.parquet with
# sfarrow::st_write_parquet() (GeoParquet: sf/sfarrow, geopandas; DuckDB
# reads it as WKB with enable_geoparquet_conversion off).
#
# Conventions every level shares:
#   - the PRIMARY geometry column is named `geometry`, WGS 84 (EPSG:4326),
#     at the source's full resolution (consumers that tile these files
#     simplify per zoom themselves — nothing here may pre-simplify)
#   - a level needing a second version of its geometry carries it as an
#     ADDITIONAL geometry column alongside (e.g. `geometry_point`) — one
#     file per geography, never a second file
#
# Scripts run from the repo root:  Rscript code/<level>.R

library(sf)
library(sfarrow)
library(dplyr)
library(readr)
library(stringr)

TERRITORY_FIPS <- c("60", "66", "69", "78") # AS, GU, MP, VI

# The build scripts fetch the Census cartographic-boundary files with
# tigris::states()/counties()/places(); cache the downloads (tigris'
# user cache directory) so repeat runs don't re-fetch.
options(tigris_use_cache = TRUE)

# Geography join-key normalizer — the SAME definition the deportationdata
# apps apply to data values at runtime, so name-keyed joins against these
# files cannot drift. Deletes non-ASCII bytes outright (not transliterate:
# older EOIR vintages carry U+FFFD where diacritics were corrupted by a
# since-fixed encoding bug upstream — "A�asco Municipio" — so deleting the
# diacritic character on both sides is the only transform that matches
# every vintage, corrupted or correctly encoded; iconv //TRANSLIT is also
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

# Non-ASCII string literals in .R source parse with Encoding() "unknown", not
# "UTF-8" — in a non-UTF-8 session locale (e.g. a CI runner set to C), `==`
# against a readr-decoded (Encoding() "UTF-8") string then compares unequal
# byte-for-byte-identical text. Tag the literal explicitly so encoding-canary
# comparisons below don't depend on the build machine's locale.
utf8_literal <- function(x) {
  Encoding(x) <- "UTF-8"
  x
}
