Sys.setenv(ARROW_DEFAULT_MEMORY_POOL = "system")

library(sf)
library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(glue)

GEO_VINTAGE <- 2025L # Census boundary vintage used by every script
TERRITORY_FIPS <- c("60", "66", "69", "78") # AS, GU, MP, VI

options(tigris_use_cache = TRUE)

# Must match the deportationdata apps' normalizer: drop non-ASCII rather than
# transliterate; chartr because toupper() is locale-dependent.
norm_geo_key <- function(x) {
  x <- iconv(x, from = "UTF-8", to = "ASCII", sub = "")
  x <- chartr("abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ", x)
  gsub("[^A-Z0-9]", "", x)
}

# Display names from NAMELSAD: counties drop " County" (any type suffix in the
# territories); places drop any parenthetical.
county_name <- function(namelsad, statefp) {
  if_else(
    statefp %in% TERRITORY_FIPS,
    str_remove(namelsad, " (County|Borough|Census Area|Municipality|District|Island|Municipio)$"),
    str_remove(namelsad, " County$")
  ) |>
    str_squish()
}
place_name <- function(namelsad) str_squish(str_remove(namelsad, "\\s*\\(.*\\)"))

# Source literals parse as Encoding "unknown", so `==` fails in non-UTF-8 locales.
utf8_literal <- function(x) {
  Encoding(x) <- "UTF-8"
  x
}
