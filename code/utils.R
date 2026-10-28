Sys.setenv(ARROW_DEFAULT_MEMORY_POOL = "system")

library(sf)
library(dplyr)
library(readr)
library(stringr)
library(purrr)
library(glue)

geo_vintage <- 2025L # Census boundary vintage used by every script
# the 50 states, DC and the five territories the Census publishes boundaries for
state_codes <- c(state.abb, "DC", "PR", "GU", "VI", "MP", "AS")

options(tigris_use_cache = TRUE)

# Source literals parse as Encoding "unknown", so `==` fails in non-UTF-8 locales.
utf8_literal <- function(x) {
  Encoding(x) <- "UTF-8"
  x
}
