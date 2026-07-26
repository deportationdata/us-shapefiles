# us-geography

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

## Layout

- `code/` — one build script per level (`states.R`, `counties.R`,
  `places.R`) plus shared helpers (`utils.R`). Run from the repo root:
  `Rscript code/states.R`. Packages: sf, sfarrow, dplyr, readr, stringr.
- `inputs/` — the geocorr2022 / tab20 extracts the county and place
  builds read, copied from `deportationdata/eoir` (`inputs/` there).
  Census cartographic-boundary files download at build time and are not
  stored.
- `data/` — the outputs (Git LFS).
