# us-shapefiles

Reference geography files for the Deportation Data Project: **states**,
**counties**, and **Census places**, each built as a single sf object —
attributes and full-resolution geometry together — and published as
Parquet with native geometry types (`data/<level>-sf.parquet`, written by
GDAL's Parquet driver with `USE_PARQUET_GEO_TYPES=ONLY`): read with
`sf::st_read()` (R, GDAL >= 3.12), geopandas, or DuckDB.

## Levels

| Level | Source | Columns (+ `geometry`) |
|---|---|---|
| `states` | 2025 CB 500k | geoid, stusps, name |
| `counties` | 2025 CB 500k | geoid, stusps, name |
| `places` | 2025 CB 500k; `pop20` from the block table | geoid, stusps, name, pop20 |

Conventions: WGS 84 (EPSG:4326); the primary geometry column is
`geometry`, at the source's full resolution (consumers that tile these
files simplify per zoom themselves); a level needing a second version of
its geometry carries it as an additional geometry column in the same
file. `pop20` is the place's 2020 Census population on its 2025 boundary (0 for
the island territories, whose 2020 blocks carry no population counts).

## Naming

County and place names come from the Census `NAMELSAD` field: counties drop
the " County" suffix (any type suffix in the island territories) and places
drop any parenthetical (`county_name()` / `place_name()` in `code/utils.R`).
The ZIP crosswalk carries the same names, so the published EOIR data joins
these files by normalized name — `norm_geo_key()` in `code/utils.R`, the
normalizer the deportationdata apps apply at runtime. Where two distinct
places normalize to the same (state, name) key, the more populous one is kept.

## ZIP crosswalk

`data/zip-xwalk.parquet` maps each 2020 Census ZCTA to a county and place —
`zcta`, `stusps`, `county`, `county_geoid`, `place`, `place_geoid` — no
geometry. `county_geoid`/`place_geoid` join `counties-sf.parquet` /
`places-sf.parquet` directly, so this file needs no name normalization,
except for the rare `place_geoid` naming a same-named CDP the places
build's (state, name) dedup dropped for a more populous twin (see
Naming) — join those by name instead. Built by `code/zip_xwalk.R` from the
block table: each ZCTA goes to the county and the place holding the largest
share of its 2020 population, or of its land area where it has no 2020
population (including the island territories). Blocks in no place compete
per state; a ZCTA whose largest share is in no place has `place`/`place_geoid`
as `NA`.

## Block table

`data/blocks-xwalk.parquet` (`code/blocks.R`) has one row per 2020 Census
tabulation block — `geoid`, `pop20`, `housing20`, `lat`, `lon`, `aland`,
`zcta`, `county_geoid`, `place_geoid`, `cousub_geoid`, `place_split` — with
the block's 2020 population and its 2025 county, place and county
subdivision from the TIGER/Line FACES files. A block split by a boundary
change since 2020 goes whole to the side holding most of its area
(`place_split` marks those). `pop20` is `NA` for the island territories. The
places build and the ZIP crosswalk aggregate this table.

## County subdivisions, the place/subdivision partition, and GNIS

- `data/cousubs-sf.parquet` — 2025 CB 500k county subdivisions (towns,
  townships, CCDs, barrios), every state and territory: geoid, stusps,
  name, namelsad, lsad, county_geoid, aland.
- `data/places-cousubs-sf.parquet` — a single non-overlapping partition of
  the country into cells built from places and county subdivisions
  (`code/places-cousubs.R`). Columns: geoid,
  stusps, name, namelsad, geo_level (`place`, `cousub`, `remainder`),
  county_geoid (NA for place cells). Town-state cells are subdivisions,
  with two kinds of place cell: the 12 PA municipalities split by a county
  line (one cell each), and CDPs that straddle subdivisions (carved out,
  leaving the subdivisions as remainders). Join data to cells through the
  xwalk, not by geoid directly. The partition is exact under planar
  geometry (`sf_use_s2(FALSE)`), which is how it was built; join points to
  it with s2 off, as `code/gnis-places-cousubs.R` does, or a point on a
  shared edge can land in two cells or none.
- `data/places-cousubs-xwalk.parquet` — every place and county
  subdivision geoid with the cell it belongs to (`cell_geoid`, `cell_level`,
  `cell_namelsad`) and the `rule` that put it there (`merged across county
  line` for the county pieces of a split PA municipality); `cell_geoid` is NA
  only for subdivisions covered by several places. `common_name`
  strips the consolidated-government suffixes from place names.
- `data/gnis-populated-places-sf.parquet` — USGS GNIS populated places as
  points (feature_id, stusps, name, county_name), from the pinned
  `inputs/DomesticNames_National_Text_<pubdate>.zip`; "(historical)"
  entries and unknown (0, 0) locations are dropped.
- `data/gnis-places-cousubs-xwalk.parquet` — each GNIS point's cell
  (`cell_geoid`, `cell_stusps`, `cell_level`, `cell_namelsad`) and how it
  was found (`match`): `cell` for a point inside a cell; `tiger` for one
  off the generalized shoreline but inside the unclipped TIGER/Line place
  or subdivision; `nearest` for one TIGER puts in water within 500 m of a
  cell; NA (nine points) for the rest, which are across the Mexican border
  or at sea with bad coordinates. `cell_stusps` can differ from `stusps`
  near a state line.

Build everything in dependency order with `./build.sh`, or name the
scripts: `./build.sh cousubs places-cousubs`.

## Layout

- `code/` — one build script per output (`blocks.R`, `states.R`,
  `counties.R`, `places.R`, `zip_xwalk.R`, ...) and shared helpers
  (`utils.R`, where `GEO_VINTAGE` sets the Census vintage). Run from the
  repo root: `Rscript code/states.R`, or `./build.sh`. Packages: sf (GDAL
  with the Parquet driver), arrow, tigris, dplyr, purrr, readr, stringr,
  glue, mirai, curl, rappdirs.
- `inputs/` — the pinned USGS GNIS zip. Census files download at build time
  and are not stored: cartographic boundaries via tigris, and the TIGER/Line
  block and FACES zips (~20 GB) into the tigris cache dir or
  `US_SHAPEFILES_CACHE`.
- `data/` — the outputs (Git LFS).
