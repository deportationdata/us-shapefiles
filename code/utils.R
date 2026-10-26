Sys.setenv(ARROW_DEFAULT_MEMORY_POOL = "system")

library(sf)
library(dplyr)
library(readr)
library(stringr)
library(purrr)

TERRITORY_FIPS <- c("60", "66", "69", "78") # AS, GU, MP, VI

options(tigris_use_cache = TRUE)

# Must match the deportationdata apps' normalizer. Drops non-ASCII rather
# than transliterating (older EOIR vintages have U+FFFD for diacritics);
# chartr because toupper() is locale-dependent.
norm_geo_key <- function(x) {
  x <- iconv(x, from = "UTF-8", to = "ASCII", sub = "")
  x <- chartr("abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ", x)
  gsub("[^A-Z0-9]", "", x)
}

# Source literals parse as Encoding "unknown", so `==` fails in non-UTF-8 locales.
utf8_literal <- function(x) {
  Encoding(x) <- "UTF-8"
  x
}
