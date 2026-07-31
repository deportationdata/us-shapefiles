# us-shapefiles

Reference geography files for the Deportation Data Project: **states**,
**counties**, and **Census places**, each built as a single sf object —
attributes and full-resolution geometry together — and published as
GeoParquet (`data/<level>-sf.parquet`): read with
`sfarrow::st_read_parquet()` (R), geopandas, or DuckDB (as WKB, with
`enable_geoparquet_conversion` off).

## Levels

| Level | Source | Columns (+ `geometry`) |
|---|---|---|
| `states` | Census cartographic boundaries, 2024 CB 500k | geoid, stusps, name |
| `counties` | 2024 CB 500k universe + geometry; geocorr2022/tab20 naming | geoid, stusps, name |
| `places` | 2020 CB 500k universe + geometry; geocorr2022/tab20 naming | geoid, stusps, name, pop20 |

Conventions: WGS 84 (EPSG:4326); the primary geometry column is
`geometry`, at the source's full resolution (consumers that tile these
files simplify per zoom themselves); a level needing a second version of
its geometry carries it as an additional geometry column in the same
file. `pop20` is the place's total 2020 Census population (0 for the
island territories, which geocorr does not cover).

## Naming

County and place names match the **published EOIR data** (the transforms
of `eoir/scripts/geography_join.R` on the same geocorr2022 / tab20
inputs), so values in the published datasets join these files by
normalized name — `norm_geo_key()` in `code/utils.R`, the same normalizer
the deportationdata apps apply at runtime. Where two distinct places
normalize to the same (state, name) key, the EOIR data cannot tell them
apart either; the more populous one is kept.

## ZIP crosswalk

`data/zip-xwalk.parquet` maps each 2020 Census ZCTA to a county and place —
`zcta`, `stusps`, `county`, `county_geoid`, `place`, `place_geoid` — no
geometry. `county_geoid`/`place_geoid` join `counties-sf.parquet` /
`places-sf.parquet` directly, so this file needs no name normalization,
except for the rare `place_geoid` naming a same-named CDP the places
build's (state, name) dedup dropped for a more populous twin (see
Naming) — join those by name instead. Built by `code/zip_xwalk.R`, which
replicates the ZCTA allocation in `eoir/scripts/geography_join.R` (largest
geocorr population share; tab20 land-area share for the island
territories) on the same inputs. A ZCTA that geocorr assigns no place has
`place`/`place_geoid` as `NA`.

## Layout

- `code/` — one build script per level (`states.R`, `counties.R`,
  `places.R`), plus the ZIP crosswalk (`zip_xwalk.R`) and shared helpers
  (`utils.R`). Run from the repo root: `Rscript code/states.R`. Packages:
  sf, sfarrow, arrow, tigris, dplyr, readr, stringr.
- `inputs/` — the geocorr2022 / tab20 extracts the county, place, and ZIP
  crosswalk builds read, copied from `deportationdata/eoir` (`inputs/`
  there). Census cartographic-boundary files download at build time (via
  tigris, cached) and are not stored.
- `data/` — the outputs (Git LFS).
