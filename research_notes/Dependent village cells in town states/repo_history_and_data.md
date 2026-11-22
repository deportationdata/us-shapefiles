# Repo history and current data: dependent villages/boroughs in the town states

Scope: git history of `code/places-county-subdivisions.R` (and its predecessor `code/places-cousubs.R`) in `/Users/graeme/github/us-shapefiles`, the two existing reports and their notes, the current parquet outputs in `data/`, and the ICE matcher in `/Users/graeme/github/ice`. Nothing was rerun or modified; all numbers are computed from files as committed at `a709a91` (working-tree `data/` is clean against HEAD). Population is 2020 block population (`pop20`) from `data/blocks-xwalk.parquet`, summed by the block's `place_geoid` / `county_subdivision_geoid`.

Source shorthand used below (all local, no URLs exist for them):
- `[git <hash>]` = commit in `/Users/graeme/github/us-shapefiles` (`git show <hash>`)
- `[xwalk@<hash>]` = `data/places-county-subdivisions-xwalk.parquet` (or `data/places-cousubs-xwalk.parquet` before `e7e83b9`) as committed at that hash, read from the local git-LFS object cache
- `[xwalk]`, `[blocks]` = current `data/places-county-subdivisions-xwalk.parquet`, `data/blocks-xwalk.parquet`
- `[report 1]` = `/Users/graeme/github/us-shapefiles/reports/US municipality cells from Census units.md` (file mtime 2026-11-09 22:17)
- `[report 2]` = `/Users/graeme/github/us-shapefiles/reports/Assigning straddling places to towns.md` (mtime 2026-11-11 16:31)
- `[memory]` = `/Users/graeme/.claude/projects/-Users-graeme-github-us-shapefiles/memory/strong-town-cell-rule.md`
- `[ice xwalk]` = `/Users/graeme/github/ice/data/city-match-crosswalk.parquet` (mtime 2026-11-17 16:20; modified relative to ICE HEAD, i.e. an uncommitted local rebuild; `city-match.R` pins us-shapefiles at `a709a91`)

---

## 1. History: how the rule evolved, what reasons were given, did it ever flip

### Takeaway
The treatment of incorporated places has never changed: Vermont villages and Connecticut boroughs/cities have been folded into their towns, and NY/MI/WI/MN cities and villages have been their own cells, in every committed build since the first one on 2026-10-25. No commit message or code comment ever gives a reason specific to Vermont villages or Connecticut boroughs; the only stated rationale ("in town_states a municipality is its own subdivision and folds into it") is true for six of the eight town states and for VT/CT cities, but false for the 30 VT villages, 9 CT boroughs and Groton city. Report 1 (Nov 9) recommended cutting them out as cells ("preferred") or else recording the fold "as a deliberate exception"; the code kept the fold, and the exception is recorded only in the session memory note, not in the code — and the current file header (rule 2) actually says a village or borough "is its own cell", which the code does not do in VT/CT.

### Cited Findings

**Commit-by-commit timeline** (file renamed `code/places-cousubs.R` -> `code/places-county-subdivisions.R` at `e7e83b9`; `git log --follow` only shows the 7 commits from `e7e83b9` on, the 3 earlier ones are on the old filename).

| Date (local) | Commit | Message | `town_states` | `cdp_fold_states` | What it did to this rule |
|---|---|---|---|---|---|
| 2026-10-25 17:30 | `032659a` | "major updates to allow use of more complicated geometry merge for ice cities" | ME NH VT MA RI CT NJ PA | NY | First version (`code/places-cousubs.R`). Both lists already exist with today's `town_states` membership. Fold needs >= 95% of the place's **area** in one cousub; a place that fits no single cousub is carved out as a cell. |
| 2026-10-25 22:07 | `122bcc1` | "cleanup and simplification" | same | NY | Comments shortened; no rule change. |
| 2026-10-26 21:27 | `a51ac27` | "places-cousubs: cell common_name on cells and xwalk" | same | NY | No rule change. |
| 2026-10-27 21:45 | `e7e83b9` | "revise" | same | "NY" | Rename to `places-county-subdivisions.R`; adds `new_england`. No rule change. |
| 2026-10-27 22:56 | `1e013cc` | "ed" | same | "NY" | No rule change. |
| 2026-11-01 17:09 | `653d6cc` | "simplifications and small name changes" | same | "NY" | No rule change. |
| 2026-11-09 20:48 | `70d8a8f` | "add countries (state dept.), csas, cbsas, add checks, rerun all" | same | "NY" | Adds checks; no rule change. |
| 2026-11-09 22:17 | (report 1 written, untracked) | | | | Recommends village cut-outs in VT/CT; CDPs never cells in the twelve states. |
| 2026-11-11 14:56 | `559841d` | "change how we handle islands" | same | "NY" | Adds `always_fold_states` (AS MP VI GU). No change for the twelve. |
| 2026-11-11 16:31 | (report 2 written, untracked) | | | | About straddling CDPs; population plurality rule. Does not address villages. |
| 2026-11-11 18:17 | `f7d1fdd` | "change how we deal with several states' cells - based on the lowest level of government (city, municipality, etc.) rather than mixes -- with some exceptions" | same | NY MI WI MN | Adds MI, WI, MN to `cdp_fold_states`; fold now by most 2020 residents (area only as fallback), no 95% threshold; "A CDP is never a cell there"; adds `cell_share`. Incorporated-place treatment unchanged. |
| 2026-11-17 15:23 | `a709a91` | "add gnis names to places; restructure cell rules; more" | same | NY MI WI MN | CDPs fold only if they carry their town's name (or name + " Center/Village/Town"); other CDPs in the twelve become cells again. Incorporated-place treatment unchanged. New header "rules" text. |

— [git 032659a], [git 122bcc1], [git a51ac27], [git e7e83b9], [git 1e013cc], [git 653d6cc], [git 70d8a8f], [git 559841d], [git f7d1fdd], [git a709a91]

**The committed data confirm the treatment never flipped.** Rule assigned to places in each committed crosswalk (identical for every commit between `122bcc1` and `559841d`):

| State / kind | `032659a` | `122bcc1` ... `559841d` | `f7d1fdd` | `a709a91` (current) |
|---|---|---|---|---|
| VT village | 33 folded | 30 folded | 30 folded | 30 folded |
| VT city | 9 folded | 10 folded | 10 folded | 10 folded |
| CT borough | 10 folded | 10 folded | 10 folded | 10 folded |
| CT city | 20 folded | 20 folded | 20 folded | 20 folded |
| NY village | 534 cell | 532 cell | 532 cell | 532 cell |
| NY city | 62 cell | 62 cell | 62 cell | 62 cell |
| MI village / city | 253 / 280 cell | 253 / 280 cell | 253 / 280 cell | 253 / 280 cell |
| WI village / city | 412 / 190 cell | 418 / 190 cell | 418 / 190 cell | 418 / 190 cell |
| MN city | 853 cell | 856 cell | 856 cell | 856 cell |
| VT CDP | 132 folded, 6 cell | 134 folded, 6 cell | 140 folded, 0 cell | 96 folded, 44 cell |
| CT CDP | 178 folded, 7 cell | 178 folded, 7 cell | 185 folded, 0 cell | 53 folded, 132 cell |
| NY CDP | 626 folded, 71 cell | 628 folded, 71 cell | 699 folded, 0 cell | 133 folded, 566 cell |
| MI CDP | 212 cell | 212 cell | 212 folded | 37 folded, 175 cell |
| WI CDP | 202 cell | 200 cell | 200 folded | 70 folded, 130 cell |
| MN CDP | 60 cell | 60 cell | 52 folded, 8 cell | 18 folded, 42 cell |

— [xwalk@032659a] through [xwalk@a709a91]. (The 33 -> 30 villages / 9 -> 10 cities change between the two Oct 25 commits is an input-vintage change, not a rule change; Essex Junction appears as a city from `122bcc1` on.)

Code used (LFS objects copied from `.git/lfs/objects/` to scratch, then):
```r
for (c in c("032659a","122bcc1","a51ac27","e7e83b9","653d6cc","70d8a8f","04a8c12","559841d","f7d1fdd","a709a91")) {
  x <- arrow::read_parquet(file.path(d, paste0(c, ".parquet")))
  x[x$geo_level == "place", ] |>
    filter(stusps %in% c("VT","CT","NY","MI","WI","MN")) |>
    mutate(kind = case_when(is_cdp ~ "CDP",
      TRUE ~ str_extract(str_remove(namelsad, " \\(balance\\)$"), "[a-z]+$"))) |>
    count(stusps, kind, rule) |> print()
}
```

**Stated reasons, quoted.**

- `032659a` header (first version), no "why":
  > `# Town states: cousubs are cells and places fold into the cousub holding`
  > `# >= fold_share of them. Elsewhere: places are cells (except NY CDPs, which`
  > `# fold like town-state places) plus each cousub's non-sliver remainder; a`
  > `# cousub with no remainder lifts into the place holding >= fold_share of it.`
  — [git 032659a]
- `e7e83b9`:
  > `# Town states: subdivisions are the cells and places fold into them; elsewhere`
  > `# places are cells and subdivisions keep remainders. NY CDPs fold too. In New`
  > `# England a town is a municipality, which matters for short names.`
  — [git e7e83b9]
- `f7d1fdd` replaces that with the first sourced rationale, which is about the twelve states as a group and about CDPs, not about villages:
  > `+# The twelve states where the Census Bureau treats towns and townships as`
  > `+# general-purpose governments (2020 PL 94-171 technical documentation, App. A,`
  > `+# pp. A-21 to A-22). A CDP is never a cell there. Every place folds in`
  > `+# town_states; only CDPs fold in cdp_fold_states. Elsewhere every place is a`
  > `+# cell.`
  > `-cdp_fold_states <- "NY"`
  > `+cdp_fold_states <- c("NY", "MI", "WI", "MN")`
  and changes the fold test from area threshold to population plurality:
  > `-# A town-state place or NY CDP folds into the unit holding >= fold_share of`
  > `-# it; one that fits no single unit becomes a cell, carved out of them.`
  > `+# A candidate folds into the unit with most of its 2020 residents, or most of`
  > `+# its area if it has no residents.`
  — [git f7d1fdd]
- `a709a91` (current) rewrites the header as three rules and gives the only "why" for folding municipalities:
  > `+# The rules:`
  > `+#   1. A cell is the Census place: a city, town, village, borough or CDP.`
  > `+#   2. In twelve states the town or township is the place. A CDP that carries`
  > `+#      its town's name is part of it; any other CDP, city, village or borough`
  > `+#      is its own cell.`
  > `+#   3. Outside any place, the cell is the rest of the township or CCD. ...`
  > `+# Steps: merge split municipalities; fold town-state municipalities and the`
  > `+# twelve states' CDPs named for their town; ...`
  > `+# equivalent to places (2020 PL 94-171 technical documentation, App. A,`
  > `+# pp. A-21 to A-22). In town_states a municipality is its own subdivision and`
  > `+# folds into it. In all twelve a CDP folds only when it carries its town's`
  > `+# name. In New England a town is a municipality, which matters for short names.`
  — [git a709a91]
- The fold-candidate code itself is unchanged in substance since `032659a`; current form (`code/places-county-subdivisions.R` lines 251-257 and 307-322):
  ```r
  fold_candidates <-
    places |>
    filter(
      stusps %in% c(town_states, always_fold_states) |
        (stusps %in% cdp_fold_states & is_cdp)
    ) |>
    anti_join(st_drop_geometry(merged_place_cells), by = "geoid")
  ...
  # A CDP stays a cell in unorganized territory, or when its name is not its
  # town's.
  kept_places <-
    fold_choice |>
    filter(
      is_cdp,
      !stusps %in% always_fold_states,
      lsad %in% unorganized_lsad |
        (place_name != cell_name &
          str_remove(place_name, town_centre_suffix) != cell_name)
    )
  ```
  The `is_cdp` condition in `kept_places` is what keeps every incorporated place in `town_states` folded regardless of name; a check enforces it: `"a fold candidate is a cell without being a kept place"`. — current `code/places-county-subdivisions.R` (= [git a709a91])
- No commit message mentions Vermont, Connecticut, villages or boroughs. There is no README in the repo. No other script in `code/` mentions villages/boroughs/town_states. — `git log`, `grep` over the repo at HEAD.

**What the earlier reports/notes recommended about VT villages and CT boroughs.**

- Report 1 states the asymmetry outright: "The project currently cuts villages out in New York and Michigan and folds them in Vermont and Connecticut. OSM's table happens to draw the same line, but the law does not: a Vermont village is the same legal animal as a New York village, and the state researcher's own judgment was that either treatment of Vermont is defensible. The stakes are small in cell counts (about 33 Vermont villages and roughly ten Connecticut boroughs plus Groton city), so this is a consistency choice more than an accuracy one." — [report 1], line 41
- Its recommendation: "**Apply one rule to dependent incorporated places: an active incorporated place is always a cell, and its parent town keeps the balance.** The project already does this for New York and Michigan villages ... Extending it to Vermont villages and to Connecticut's boroughs and Groton city removes an asymmetry the law does not support, at a cost of a few dozen new balance cells. If folding is kept in those two states because the state base layers and OSM treat the town as primary, record it as a deliberate exception." — [report 1], line 91
- Its summary table row: "CT, VT | County subdivision | Cut out as cells with a town balance (preferred), or keep folded as a documented exception | ... | Remove straddling-CDP cells; decide villages and boroughs". For NY and MI: "Village is a cell; town[ship] keeps the balance". For WI, MN: "Minnesota's few dependent cities are cells". — [report 1], lines 82-85
- Evidence cited there for folding being defensible: OSM tags "Connecticut and Vermont nest boroughs and villages at 9 beneath a level-8 town" while "Michigan townships and New York towns sit at 7 with cities and villages at 8" (report flags some cells of that table as inferred by the extraction tool); Vermont "stores towns and villages as separate, topologically aligned feature classes, and its health department offers both a towns-only layer and a 289-unit 'municipalities with villages' layer"; NY and MI state GIS publish villages as a separate layer over a cities+towns partition. — [report 1], lines 21, 27
- The underlying note: "CT and VT are the two town states where folding discards real (dependent) governments: CT's ~9 boroughs and City of Groton, and VT's ~33 incorporated villages. In both, state sources treat the town as the primary unit (CT: '169 towns'; VT: 256 towns with villages as a separate topologically nested class), so folding is consistent with the state's primary municipal layer, but VT legally resembles NY (village residents pay both town and village tax). Treating VT villages as NY-style cut-outs would be equally defensible". — `research_notes/US municipality cells from Census units/state_structures_and_state_practice.md`, line 86
- Census Bureau description quoted in the notes: "All incorporated places (cities and boroughs) in Connecticut are dependent on the town in which they are located. One borough and all but one of the State's twenty cities are coextensive with a single town ... The incorporated places in Vermont are either cities, all of which are independent of MCDs, or villages, all of which are dependent. Unlike Connecticut, none of the dependent villages in Vermont coincide with a town." — `research_notes/US municipality cells from Census units/census_bureau_practice.md`, line 74 (quoting GARM ch. 8)
- Report 2 and its notes concern straddling CDPs (population-plurality assignment, published shares); they contain no recommendation on incorporated villages or boroughs. — [report 2]

**Did the code follow the recommendation?**

- Followed at `f7d1fdd` (Nov 11, two days after report 1, two hours after report 2): CDPs never cells in the twelve states; MI/WI/MN added; population-plurality fold; `cell_share` published. — [git f7d1fdd]
- Not followed for villages: `f7d1fdd` took report 1's fallback ("keep folded") rather than its preferred option. The session memory records it as intentional: "On 2026-11-11 Graeme chose the cell rule ... NY/MI/WI/MN keep incorporated places as cells; VT villages and CT boroughs stay folded on purpose"; "**Why:** policy clarity, not accuracy. A rerun of ICE's matcher showed zero change in match rate ..."; "**How to apply:** don't re-argue the rule from ICE accuracy." — [memory]
- Report 1's condition "record it as a deliberate exception" is not met in the code: neither VT nor CT, nor "village" in the sense of a Vermont village, nor "borough" appears in any comment explaining the fold. — current `code/places-county-subdivisions.R`
- `a709a91` (Nov 17) then reversed report 1's headline recommendation for CDPs (a CDP not named for its town is a cell again in all twelve states), without touching incorporated places. — [git a709a91], [memory] ("So 'a CDP never is a cell' above no longer holds")

### Inferences
- The VT/CT fold is an inherited side effect of the very first design (Oct 25: "town states: cousubs are cells and places fold"), written when the mental model was "in these eight states a place is its own subdivision". It was never separately decided for dependent villages until Nov 11, when it was consciously kept, and the reason on record is consistency with the state's primary layer / policy clarity rather than anything about villages themselves.
- The current header is internally inconsistent with the code. Rule 2 says "any other CDP, city, village or borough is its own cell", and the constants comment says "In town_states a municipality is its own subdivision and folds into it." For the 41 dependent places in VT/CT (section 2) the municipality is not its own subdivision, yet it folds, and under rule 2 as written the 14 differently named VT villages and 6 differently named CT boroughs would be cells. Either the text or the code is not what was intended.
- Since `a709a91` the asymmetry is sharper than when report 1 was written: an unincorporated CDP not named for its town is now a cell in VT/CT, while an incorporated village or borough not named for its town is not (examples in section 2, table 2e).
- Membership of `town_states` vs `cdp_fold_states` tracks whether incorporated places are (mostly) independent of county subdivisions in Census geography, with VT/CT as the misfits in the first list (dependent villages/boroughs) and WI/MN as apparent misfits in the second (independent places; section 2, table 2f). For WI/MN the list choice only changes labels (cell geoid is the place's, subdivision "lifted into place") not geometry.

### Gaps
- No written reason exists in the repo for why VT/CT were put in `town_states` on Oct 25 rather than treated like NY; the conversation(s) in which the first version was designed were not available. The Nov 11 reasoning is known only via the memory note's one-line summary.
- I did not find where "policy clarity" was spelled out; whether the user specifically weighed VT villages vs NY villages on Nov 11 or simply left `town_states` alone is not documented.
- Whether the rule 2 header wording at `a709a91` ("village or borough is its own cell") was meant to describe NY/MI only, or signals an intent to cut VT/CT villages out that was not implemented, cannot be determined from the repo.

---

## 2. Current data: which places are affected

### Takeaway
The rule bites on exactly 41 incorporated places, all in VT and CT: 30 Vermont villages (24,581 residents, 3.8% of the state), 9 Connecticut boroughs (14,341) and Groton city (9,387), plus the technical case of Milford city (balance); none straddles a town line (every `cell_share` is 1). In the other six town states every one of the 1,427 folded incorporated places is coextensive with a same-named subdivision, so the fold is a relabel. On the other side, Wisconsin has no dependent incorporated place at all and Minnesota has 4 (3,592 people); dependent villages kept as cells are a New York (525 villages, 1.81 million people) and Michigan (253 villages, 270,795 people) phenomenon.

### Cited Findings

All tables below: [xwalk] + [blocks]. Shared setup:

```r
library(arrow); library(dplyr); library(stringr)
town_states <- c("ME","NH","VT","MA","RI","CT","NJ","PA"); cdp_fold_states <- c("NY","MI","WI","MN")
x <- read_parquet("data/places-county-subdivisions-xwalk.parquet")
b <- read_parquet("data/blocks-xwalk.parquet",
  col_select = c("pop20","place_geoid","county_subdivision_geoid")) |> mutate(pop20 = coalesce(pop20, 0L))
place_pop  <- b |> filter(!is.na(place_geoid)) |> summarise(pop = sum(pop20), .by = place_geoid)
cousub_pop <- b |> summarise(cs_pop = sum(pop20), .by = county_subdivision_geoid)
pxc <- b |> filter(!is.na(place_geoid)) |>
  summarise(pop = sum(pop20), blocks = n(), .by = c(place_geoid, county_subdivision_geoid))
type_of <- function(namelsad) str_extract(str_remove(namelsad, " \\(balance\\)$"), "[A-Za-z]+$")
places <- x |> filter(geo_level == "place"); cs <- x |> filter(geo_level == "county_subdivision")

folded <- places |>
  filter(stusps %in% town_states, !is_cdp, cell_geoid != geoid | is.na(cell_geoid)) |>
  mutate(type = type_of(namelsad)) |>
  left_join(place_pop, by = c("geoid" = "place_geoid")) |>
  left_join(cs |> select(cell_geoid = geoid, cell_name = name, cell_aland = aland), by = "cell_geoid") |>
  left_join(cousub_pop, by = c("cell_geoid" = "county_subdivision_geoid")) |>
  left_join(pxc |> summarise(n_cousubs = n(), n_cousubs_pop = sum(pop > 0), .by = place_geoid),
            by = c("geoid" = "place_geoid")) |>
  mutate(same_name = name == cell_name,
         pop_share_of_town = pop / cs_pop, area_share_of_town = aland / cell_aland,
         coextensive = same_name & abs(pop_share_of_town - 1) < 0.005 & abs(area_share_of_town - 1) < 0.01)
```
"Town" population/area are those of the whole Census county subdivision the place folds into (not of the remainder cell). "Coextensive" = same name and the place holds 100% (+-0.5% / 1%) of the subdivision's residents and land; in practice every coextensive case is exactly 1.0000 on both.

**2a. All incorporated places in the twelve states, by rule** (`places |> filter(!is_cdp) |> count(stusps, type, rule)` with pop)

| State | Type | Rule | n | 2020 pop |
|---|---|---|---|---|
| CT | borough | folded into subdivision | 10 | 45,880 |
| CT | city | folded into subdivision | 20 | 1,365,500 |
| MA | city | folded into subdivision | 58 | 3,813,455 |
| ME | city | folded into subdivision | 23 | 385,116 |
| NH | city | folded into subdivision | 13 | 435,301 |
| NJ | borough | folded into subdivision | 252 | 1,863,892 |
| NJ | city | folded into subdivision | 52 | 2,231,961 |
| NJ | town | folded into subdivision | 15 | 280,921 |
| NJ | village | folded into subdivision | 3 | 39,427 |
| NJ | "Princeton" (no LSAD word) | folded into subdivision | 1 | 30,681 |
| PA | borough | folded into subdivision | 941 | 2,402,563 |
| PA | borough | cell: merged across county line | 11 | 29,825 |
| PA | city | folded into subdivision | 54 | 3,065,261 |
| PA | city | cell: merged across county line | 1 | 75,781 |
| PA | municipality | folded into subdivision | 6 | 164,538 |
| PA | town | folded into subdivision | 1 | 12,711 |
| RI | city | folded into subdivision | 8 | 570,420 |
| VT | city | folded into subdivision | 10 | 129,879 |
| VT | village | folded into subdivision | 30 | 24,581 |
| MI | city | cell | 280 | 4,834,934 |
| MI | village | cell | 253 | 270,795 |
| MN | city | cell | 856 | 4,768,413 |
| NY | city | cell | 62 | 11,085,140 |
| NY | village | cell | 532 | 1,925,950 |
| WI | city | cell | 190 | 3,270,925 |
| WI | village | cell | 418 | 1,059,186 |

— [xwalk], [blocks]

**2b. Vermont: genuinely dependent places folded into a town (30 villages; all `cell_share` = 1; none coextensive)**

| Village | 2020 pop | Folds into (cell) | Name = town name | Town pop | Village share of town pop | Village share of town land |
|---|---|---|---|---|---|---|
| Bellows Falls | 2,747 | Rockingham town | no | 4,832 | 56.9% | 3.3% |
| Swanton | 2,328 | Swanton town | yes | 6,710 | 34.7% | 1.6% |
| Morrisville | 2,086 | Morristown town | no | 5,434 | 38.4% | 3.9% |
| North Bennington | 1,716 | Bennington town | no | 15,333 | 11.2% | 4.5% |
| Enosburg Falls | 1,356 | Enosburgh town | no | 2,810 | 48.3% | 7.4% |
| Jericho | 1,333 | Jericho town (remainder) | yes | 5,104 | 26.1% | 3.9% |
| Johnson | 1,332 | Johnson town (remainder) | yes | 3,491 | 38.2% | 2.6% |
| Poultney | 1,079 | Poultney town (remainder) | yes | 3,020 | 35.7% | 1.5% |
| Woodstock | 900 | Woodstock town (remainder) | yes | 3,005 | 30.0% | 2.7% |
| Orleans | 788 | Barton town | no | 2,872 | 27.4% | 2.1% |
| Manchester | 783 | Manchester town | yes | 4,484 | 17.5% | 8.4% |
| Ludlow | 773 | Ludlow town | yes | 2,172 | 35.6% | 3.9% |
| Jeffersonville | 750 | Cambridge town | no | 3,839 | 19.5% | 1.2% |
| Barton | 690 | Barton town | yes | 2,872 | 24.0% | 2.7% |
| Derby Line | 687 | Derby town | no | 4,579 | 15.0% | 1.5% |
| Derby Center | 635 | Derby town | no | 4,579 | 13.9% | 2.8% |
| North Troy | 631 | Troy town | no | 1,722 | 36.6% | 5.2% |
| Alburgh | 571 | Alburgh town | yes | 2,106 | 27.1% | 2.2% |
| Saxtons River | 479 | Rockingham town | no | 4,832 | 9.9% | 1.1% |
| Newbury | 447 | Newbury town | yes | 2,293 | 19.5% | 7.8% |
| Wells River | 431 | Newbury town | no | 2,293 | 18.8% | 3.0% |
| Hyde Park | 410 | Hyde Park town (remainder) | yes | 3,020 | 13.6% | 3.0% |
| Westminster | 287 | Westminster town (remainder) | yes | 3,016 | 9.5% | 3.0% |
| West Burke | 281 | Burke town (remainder) | no | 1,651 | 17.0% | 1.4% |
| Marshfield | 229 | Marshfield town | yes | 1,583 | 14.5% | 0.6% |
| Jacksonville | 213 | Whitingham town | no | 1,344 | 15.9% | 3.1% |
| Cambridge | 210 | Cambridge town | yes | 3,839 | 5.5% | 2.0% |
| Albany | 166 | Albany town | yes | 976 | 17.0% | 4.0% |
| Old Bennington | 156 | Bennington town | no | 15,333 | 1.0% | 0.9% |
| Newfane | 87 | Newfane town | yes | 1,645 | 5.3% | 0.4% |

Totals: 30 villages, 24,581 residents. Same name as town: 16 villages, 11,625 residents. Different name: 14 villages, 12,956 residents (Bellows Falls, Derby Center, Derby Line, Enosburg Falls, Jacksonville, Jeffersonville, Morrisville, North Bennington, North Troy, Old Bennington, Orleans, Saxtons River, Wells River, West Burke). Twenty-three fold into a whole-town cell and seven into a "(remainder)" cell (the town has had a CDP cell cut out of it). Six towns hold two villages each (Rockingham, Bennington, Derby, Newbury, Cambridge, Barton), so the 30 villages sit in 24 distinct towns. Size: min 87, quartiles 318 / 661 / 1,034, max 2,747; 22 of 30 are under 1,000. — [xwalk], [blocks]; code: `folded |> filter(stusps == "VT", !coextensive)`

**2c. Vermont: cities coextensive with their own subdivision (fold is a relabel; 10 cities, 129,879 residents; all same name, 100% of subdivision pop and land)**
Burlington 44,743; South Burlington 20,292; Rutland 15,807; Essex Junction 10,590; Barre 8,491; Montpelier 8,074; Winooski 7,997; St. Albans 6,877; Newport 4,455; Vergennes 2,553. Each folds into the county subdivision of the same name and LSAD ("Burlington city" -> "Burlington city"). — [xwalk], [blocks]

**2d. Connecticut: dependent places folded into a town (all `cell_share` = 1)**

| Place | Type | 2020 pop | Folds into (cell) | Name = town name | Town pop | Share of town pop | Share of town land |
|---|---|---|---|---|---|---|---|
| Groton | city | 9,387 | Groton town (remainder) | yes | 38,411 | 24.4% | 9.9% |
| Danielson | borough | 4,155 | Killingly town (remainder) | no | 17,752 | 23.4% | 2.3% |
| Jewett City | borough | 3,328 | Griswold town | no | 11,402 | 29.2% | 2.0% |
| Newtown | borough | 1,914 | Newtown town (remainder) | yes | 27,173 | 7.0% | 4.0% |
| Woodmont | borough | 1,486 | Milford town | no | 52,044 | 2.9% | 1.2% |
| Litchfield | borough | 1,179 | Litchfield town | yes | 8,192 | 14.4% | 2.5% |
| Stonington | borough | 976 | Stonington town (remainder) | yes | 18,335 | 5.3% | 0.9% |
| Bantam | borough | 720 | Litchfield town | no | 8,192 | 8.8% | 1.8% |
| Groton Long Point | borough | 530 | Groton town (remainder) | no | 38,411 | 1.4% | 1.4% |
| Fenwick | borough | 53 | Old Saybrook town (remainder) | no | 10,481 | 0.5% | 2.6% |
| Milford city (balance) | city | 50,558 | Milford town | no (name is "Milford city (balance)") | 52,044 | 97.1% | 98.8% |

Totals for the genuinely dependent ten: 9 boroughs with 14,341 residents + Groton city 9,387 = 23,728. Same name as town: Groton city, and boroughs Litchfield, Newtown, Stonington (3 boroughs, 4,069). Different name: Bantam, Danielson, Fenwick, Groton Long Point, Jewett City, Woodmont (6 boroughs, 10,272). Milford city (balance) is the consolidated city of Milford minus Woodmont borough; it is not a village-in-a-town case and fails the coextensive test only because Woodmont sits inside the same town. Five fold into whole-town cells and six into "(remainder)" cells. — [xwalk], [blocks]; code: `folded |> filter(stusps == "CT", !coextensive)`

**2e. Connecticut: coextensive with a same-named town (19 places, 1,337,094 residents; fold is a relabel "X city" -> "X town")**
18 cities (1,305,555): Bridgeport 148,654; Stamford 135,470; New Haven 134,023; Hartford 121,065; Waterbury 114,403; Norwalk 91,184; Danbury 86,518; New Britain 74,135; Meriden 60,850; Bristol 60,833; West Haven 55,584; Middletown 47,717; Shelton 40,869; Norwich 40,125; Torrington 35,515; New London 27,367; Ansonia 18,918; Derby 12,325. 1 borough: Naugatuck 31,539. — [xwalk], [blocks]

**CDP cells now coexist with folded incorporated places in the same towns (new at `a709a91`).** CDP cells whose residents are mostly in a town that also has a folded dependent village/borough:

| State | Town | CDP that is a cell (pop) | Incorporated place folded in that town (pop) |
|---|---|---|---|
| CT | Groton | Conning Towers-Nautilus Park (8,870), Long Hill (3,948), Old Mystic (3,493), Poquonock Bridge (1,686), Noank (1,654) | Groton city (9,387), Groton Long Point borough (530) |
| CT | Killingly | Dayville (631) | Danielson borough (4,155) |
| CT | Newtown | Sandy Hook (9,114), Botsford (499), Dodgingtown (380), Hawleyville (151) | Newtown borough (1,914) |
| CT | Old Saybrook | Saybrook Manor (1,172) | Fenwick borough (53) |
| CT | Stonington | Pawcatuck (5,433), Mystic (3,193) | Stonington borough (976) |
| VT | Burke | East Burke (94) | West Burke village (281) |
| VT | Hyde Park | North Hyde Park (316) | Hyde Park village (410) |
| VT | Jericho | Underhill Flats (405) | Jericho village (1,333) |
| VT | Poultney | East Poultney (288) | Poultney village (1,079) |
| VT | Westminster | North Westminster (262) | Westminster village (287) |
| VT | Woodstock | West Woodstock (401), South Woodstock (109) | Woodstock village (900) |

Statewide: VT has 44 CDP cells (25,492 residents) and 96 folded CDPs (97,140); CT has 132 CDP cells (372,184) and 53 folded CDPs (462,431). — [xwalk], [blocks]
```r
cdp_town <- pxc |> slice_max(pop, n = 1, by = place_geoid, with_ties = FALSE)
x |> filter(stusps %in% c("VT","CT"), geo_level == "place", is_cdp, rule == "cell") |>
  inner_join(cdp_town, by = c("geoid" = "place_geoid")) |>
  inner_join(dep |> summarise(folded_here = str_c(namelsad, " (", pop, ")", collapse = "; "), .by = cell_geoid),
             by = c("county_subdivision_geoid" = "cell_geoid"))   # dep = folded |> filter(stusps %in% c("VT","CT"), !coextensive)
```

**2f. Other six town states (ME NH MA RI NJ PA): the rule does not bite.**
- Folded incorporated places that are not coextensive with their subdivision: **0 rows**. Folded into a differently named unit: **0 rows**. — code: `folded |> filter(!stusps %in% c("VT","CT"), !coextensive)` and `... !same_name`
- Counts of folded, coextensive, same-name places: MA 58 cities (3,813,455); ME 23 cities (385,116); NH 13 cities (435,301); RI 8 cities (570,420); NJ 323 (252 boroughs, 52 cities, 15 towns, 3 villages, Princeton; 4,446,882 total); PA 1,002 (941 boroughs, 54 cities, 6 "municipality", 1 town; 5,645,073 total). All fold into a cell of level `county_subdivision` and `cell_type` "municipality". — [xwalk], [blocks]
- The only town-state incorporated places that are cells are the 12 PA municipalities split by a county line (11 boroughs, 1 city; rule "cell: merged across county line"). — [xwalk]
- Cell-type labelling differs for the VT/CT cases: the 30 VT villages and all 30 CT incorporated places fold into cells typed `township` (the town), whereas in the other six states the target cell is typed `municipality`. (`count(folded, stusps, rule, cell_level, cell_type)`: CT 24 county_subdivision/township + 6 remainder/township; VT 10 county_subdivision/municipality [the cities] + 23 county_subdivision/township + 7 remainder/township.) — [xwalk]

**2g. NY, MI, WI, MN: incorporated place cells, dependent vs independent.**
Method: every incorporated place in these four states is a cell (rule "cell"). Each place x county-subdivision block intersection is classified by what the subdivision became in the crosswalk: "lifted into place" with `cell_geoid` = this place (the place is its own subdivision, independent), or rule "cell" with `cell_level` "remainder" (the place sits inside a town/township that keeps a remainder cell, dependent).
```r
inc <- places |> filter(stusps %in% cdp_fold_states, !is_cdp) |> mutate(type = type_of(namelsad))
parts <- pxc |>
  inner_join(inc |> filter(cell_geoid == geoid) |> select(place_geoid = geoid, stusps, type, namelsad), by = "place_geoid") |>
  left_join(cs |> select(county_subdivision_geoid = geoid, cs_rule = rule, cs_cell = cell_geoid, cs_cell_level = cell_level),
            by = "county_subdivision_geoid") |>
  mutate(part = case_when(
    cs_rule == "lifted into place" & cs_cell == place_geoid ~ "own",
    cs_rule == "cell" & cs_cell_level == "remainder" ~ "dep",
    TRUE ~ "other"))
cls <- parts |> summarise(pop = sum(pop), n_own = sum(part == "own"), n_dep = sum(part == "dep"),
                          n_other = sum(part == "other"), .by = c(place_geoid, stusps, type, namelsad)) |>
  mutate(status = case_when(n_dep == 0 & n_other == 0 ~ "independent", n_own == 0 & n_other == 0 ~ "dependent",
                            n_own > 0 & n_dep > 0 & n_other == 0 ~ "mixed", TRUE ~ "other"))
```

| State | Status | n places | 2020 pop | Share of state's incorporated places | Share of their pop |
|---|---|---|---|---|---|
| NY | dependent (inside a town that keeps a remainder cell) | 518 (517 villages + Sherrill city) | 1,736,355 | 87.2% | 13.3% |
| NY | dependent, but town has no remainder cell ("other") | 8 villages | 81,494 | 1.3% | 0.6% |
| NY | independent (own subdivision) | 68 (61 cities + 7 villages) | 11,193,241 | 11.4% | 86.0% |
| MI | dependent | 253 (all 253 villages) | 270,795 | 47.5% | 5.3% |
| MI | independent | 279 cities | 4,827,924 | 52.3% | 94.6% |
| MI | mixed | 1 (St. Louis city) | 7,010 | 0.2% | 0.1% |
| WI | independent | 608 (190 cities + 418 villages) | 4,330,111 | 100% | 100% |
| WI | dependent | 0 | 0 | 0% | 0% |
| MN | independent | 852 cities | 4,764,821 | 99.5% | 99.9% |
| MN | dependent | 4 cities | 3,592 | 0.5% | 0.08% |

— [xwalk], [blocks]

Details:
- MN's four dependent cities: Aurora (1,678, in White township), Nashwauk (970, Nashwauk township, with zero-population blocks in Lone Pine and Greenway townships), Marble (610, Greenway township), Calumet (334, Greenway township). — [xwalk], [blocks]
- NY's "other" eight are villages in towns wholly covered by villages, whose subdivision has rule "no cell: covered by several places": Port Chester (31,693) and Rye Brook (10,047) in Rye town; Mamaroneck village (20,151; 12,278 in Mamaroneck town, 7,873 in Rye town); Pelham (7,326) and Pelham Manor (5,752) in Pelham town; Tuxedo (3,166) and Tuxedo Park (645) in Tuxedo town; Harriman (2,714; 2,043 in Monroe town, 671 in Woodbury town, which is itself lifted into Woodbury village). Legally dependent; counted with dependent in the comparison below (NY dependent villages = 517 + 8 = 525 with 1,814,772 residents). — [xwalk], [blocks]
- NY's seven independent villages (coextensive town-villages, town "lifted into place"): Kiryas Joel 32,954; Harrison 28,218; Scarsdale 18,253; Woodbury 11,526; Mount Kisco 10,959; East Rochester 6,334; Green Island 2,934 (total 111,178). NY's one dependent city: Sherrill (3,077). — [xwalk], [blocks]
- MI's "mixed" St. Louis city is its own subdivision plus zero-population blocks coded to Bethany township; effectively independent. — [xwalk], [blocks]
- County subdivisions by outcome (`cs |> count(stusps, rule, cell_level)`): NY 389 whole-town cells, 548 remainders, 74 lifted into a place, 3 no cell; MI 787 whole, 453 remainders, 300 lifted; WI 1,106 whole, 136 remainders, 671 lifted; MN 1,810 whole, 47 remainders, 900 lifted. WI/MN remainders exist because of CDP cells (and MN's 4 cities), not because of incorporated villages. — [xwalk]
- Dependent place cells sharing the name of the town holding most of their residents: NY 187 of 525 villages (538,493 residents); MI 97 of 253 villages (118,239); MN 1 of 4 (Nashwauk). — [xwalk], [blocks]
- Villages straddling more than one town/township (blocks with residents in 2+ subdivisions): NY 67 villages in two towns and 3 in three; MI 40 villages in two townships, 2 in three, 1 in four. — [blocks]

**2h. Population comparison: folded VT/CT dependents vs NY/MI dependent villages kept as cells.**

| Group | Treatment | n | 2020 pop | State 2020 pop | Share of state |
|---|---|---|---|---|---|
| VT villages | folded into town | 30 | 24,581 | 643,077 | 3.82% |
| CT boroughs (dependent; excl. Naugatuck) | folded into town | 9 | 14,341 | 3,605,944 | 0.40% |
| CT Groton city | folded into town | 1 | 9,387 | 3,605,944 | 0.26% |
| VT + CT dependent total | folded | 40 | 48,309 | | |
| NY dependent villages (517 + 8) | own cells | 525 | 1,814,772 | 20,201,249 | 8.98% |
| NY Sherrill city | own cell | 1 | 3,077 | | |
| MI villages | own cells | 253 | 270,795 | 10,077,331 | 2.69% |
| NY + MI dependent villages total | own cells | 778 | 2,085,567 | | |

Shares are my division of the two computed columns. — [xwalk], [blocks]

Size distribution of the dependent places (2020 pop):

| Group | n | min | Q1 | median | Q3 | max | under 1,000 |
|---|---|---|---|---|---|---|---|
| VT villages (folded) | 30 | 87 | 318 | 661 | 1,034 | 2,747 | 22 |
| CT dependent incl. Milford balance (folded) | 11 | 53 | 848 | 1,486 | 3,742 | 50,558 | 4 |
| MI villages (cells) | 253 | 104 | 377 | 712 | 1,308 | 10,584 | 163 |
| NY dependent, town has remainder (cells) | 518 | 50 | 763 | 1,702 | 3,732 | 59,169 | 175 |

— [xwalk], [blocks]

**2i. Straddlers.** Zero VT villages and zero CT boroughs/cities have `cell_share` < 1, and zero have blocks in more than one county subdivision (`n_cousubs` = 1 for all 70 VT/CT incorporated places). — [xwalk], [blocks]; code: `folded |> filter(stusps %in% c("VT","CT"), cell_share < 1)` -> 0 rows.

### Inferences
- Wisconsin and Minnesota behave like NJ/PA for incorporated places (independent of towns/townships); only their CDP handling puts them in `cdp_fold_states`. Moving WI/MN between the two lists would change only which geoid/level labels a city's cell (place cell with subdivision lifted vs subdivision cell with place folded), except for MN's 4 dependent cities, which would be folded into their townships. So the substantive split in the twelve states is: dependent villages are cells in NY and MI (778 places, 2.09 million people) and folded in VT and CT (40 places, 48 thousand people).
- Vermont villages are small relative to New York's but nearly the same size profile as Michigan's (median 661 vs 712; 73% vs 64% under 1,000), and as a share of state population (3.8%) they outweigh Michigan's villages (2.7%). "Too small to matter" would apply to Michigan about as well as to Vermont.
- If the CDP name test were applied to incorporated places, 16 VT villages + 3 CT boroughs + Groton city share their town's name and would stay folded; 14 VT villages (12,956 people) and 6 CT boroughs (10,272) would become cells. If instead all dependents were cut out NY-style, the cost is 40 new place cells and 32 towns that would be (or already are) remainder cells: VT 30 villages across 24 towns, 7 of which are already remainder cells (Jericho, Johnson, Poultney, Woodstock, Hyde Park, Westminster, Burke), so 17 newly cut towns; CT 10 places across 8 towns (Groton, Killingly, Griswold, Newtown, Milford, Litchfield, Stonington, Old Saybrook), 5 of which are already remainders (Groton, Killingly, Newtown, Stonington, Old Saybrook), so 3 newly cut towns. (Town counts are hand-derived from tables 2b and 2d.)
- Because no VT village or CT borough straddles a town line, folding them loses no information that `cell_share` would need to carry; the fold is exact containment.

### Gaps
- Population is 2020 census block population on the crosswalk's place vintage; no current-year estimates were used, and village dissolutions/incorporations after the boundary vintage are not reflected (Essex Junction is already a city in this vintage).
- "Dependent" is inferred from geometry (place lies inside a subdivision that is a different entity), not from the Census `classfp` codes (C1 vs C5 etc.), which are not carried in the crosswalk parquet. The two should agree but I did not cross-check against `data/places-sf.parquet`.
- Scratch columns `pop_own`/`pop_dep` in my first script were miscomputed (name shadowing inside `summarise`) and are not reported; the status classification uses part counts only and is unaffected.

---

## 3. Downstream use: how ICE's matcher treats folded places, and how many records are involved

### Takeaway
ICE's `city-match.R` matches a city string to a Census place name first (tier T2) and then reports the place's cell, so a string naming a folded village or borough resolves to the enclosing town with `rule` = "folded into subdivision" and `cell_share` carried along. In the locally built match output, only 51 arrest rows across 6 names hit a genuinely dependent VT/CT place (37 rows on 3 Vermont villages, 12 rows on 2 dependent Connecticut boroughs, 2 rows on Groton city); by contrast 4,801 rows match NY dependent places (villages plus Sherrill city) and 216 match MI villages that are cells.

### Cited Findings

**How folded places are matched** — `/Users/graeme/github/ice/code/city-match.R` (ICE HEAD `74eaefd`, 2026-11-17):
- Pins the crosswalk: `shp_url <- "https://github.com/deportationdata/us-shapefiles/raw/a709a91b7d78e53bed9b665294168fa5e9df6c2d/data"` (line 21), reads `places-county-subdivisions-xwalk.parquet`, drops rows with no cell.
- Tiers (header comment): "T2: Exact matches with a named place / T3: Exact matches with a county subdivision / T4: Exact matches with a county / T5: Remaining city/state keys matched to GNIS places corresponding to single points within a cell".
- `places_lookup` keys every place (cell or not) by `normalize_city(name)` + state and carries `cell_geoid, cell_share, place_county_share, cell_level, cell_namelsad, rule`; where an incorporated place and a CDP share a key the incorporated one wins (`slice_min(is_cdp, n = 1, ...)`), and a key that is still ambiguous is dropped (`filter(n() == 1, ...)`). So a folded village is matched by its own name and the output `geoid` is the town's cell; the village's geoid survives as `raw_geoid`/`raw_name`.
- Places are tried before subdivisions, so a string equal to both a village and its town (e.g. "swanton") is attributed to the village record (`raw_name` "Swanton village") — harmless when the village is folded, because the cell is the town either way.
- Output written to `data/city-match-crosswalk.parquet` with columns `key_city, key_state, n_rows, geoid, geo_level, matched_name, matched_name_census, raw_geoid, raw_level, raw_name, is_cdp, cell_share, place_county_share, rule, match_tier, confidence, reason`.

**Counts from the local output** — [ice xwalk]. Code:
```r
m <- arrow::read_parquet("/Users/graeme/github/ice/data/city-match-crosswalk.parquet")
v <- m |> filter(rule == "folded into subdivision", raw_level == "place",
                 str_sub(raw_geoid, 1, 2) %in% c("50", "09"), !is_cdp)
```
- Whole file: 14,843 city/state strings; T2 place exact 8,373 strings / 735,806 rows; T3 subdivision exact 504 / 13,196; all "folded into subdivision" place matches nationally 903 strings / 58,755 rows. — [ice xwalk]
- VT/CT non-CDP folded places matched (all tier "T2 place exact", all `cell_share` = 1):

| State | Type | Strings | Rows |
|---|---|---|---|
| CT | city | 20 | 1,534 |
| CT | borough | 3 | 15 |
| VT | city | 8 | 156 |
| VT | village | 3 | 37 |

- Genuinely dependent places among them:

| key_city | State | Rows | Matched place | Reported cell (`matched_name_census`) | Name = town |
|---|---|---|---|---|---|
| swanton | VT | 31 | Swanton village | Swanton town | yes |
| derby line | VT | 5 | Derby Line village | Derby town | no |
| cambridge | VT | 1 | Cambridge village | Cambridge town | yes |
| newtown | CT | 9 | Newtown borough | Newtown town (remainder) | yes |
| danielson | CT | 3 | Danielson borough | Killingly town (remainder) | no |
| groton | CT | 2 | Groton city | Groton town (remainder) | yes |

  Total 51 rows; only 8 rows (Derby Line 5, Danielson 3) carry a name that differs from the town they are reported under. The third CT borough string is Naugatuck (3 rows), which is coextensive with its town. — [ice xwalk]
- Coextensive VT/CT cities matched (relabel only): CT — Hartford 562, Danbury 257, Waterbury 134, Bridgeport 123, Stamford 105, Meriden 65, New Haven 60, New Britain 55, Middletown 29, New London 28, Torrington 24, Norwalk 22, Milford [city (balance)] 21, Derby 15, Norwich 11, West Haven 11, Bristol 7, Shelton 2, Ansonia 1 (with Groton's 2 = 1,534). VT — St. Albans 76, Burlington 60, South Burlington 8, Newport 5, Rutland 3, Essex Junction 2, Barre 1, Winooski 1 (156). — [ice xwalk]
- State context: Vermont has 243 rows in total across all tiers (T2 217, T3 20, T6 unresolved 4, T0 2); Connecticut 1,980 (T2 1,697, T3 127, T0 120, T6 26, T5 6, T1 4). — [ice xwalk]
- Comparison, village cells: strings matched to a NY or MI place whose `raw_name` ends " village" with rule "cell": NY 222 strings / 4,851 rows; MI 37 strings / 216 rows. Restricted to the dependent places of table 2g (joined on `raw_geoid`): NY 217 strings / 4,801 rows, of which 93 strings / 2,609 rows are villages sharing their town's name and 124 / 2,192 are not; MI 37 strings / 216 rows (16 / 128 same name, 21 / 88 different). — [ice xwalk], [xwalk], [blocks]

**Related earlier finding in the ICE repo** — `/Users/graeme/github/ice/cell-level-findings.md` (untracked, dated "11 November 2026", built on the pre-`f7d1fdd` crosswalk, so its counts differ slightly from the above):
- "**The real errors come from shared names, not from cells.** A borough or village that shares a name with a neighbouring or enclosing township gets the match because places are tried first. Freehold (NJ), Alden and Champlain (NY) are the large cases."
- "**New York: village inside a town of the same name.** 98 names, 2,659 rows. NY villages are cells, so there is no whole-town cell to fall back on." Examples: "**Alden (1,135 rows)** is matched to the village (2,604 people). 99.5% are custodial arrests and the landmark is Wende Correctional Facility; the prison blocks are in the town about two miles outside the village." "**Champlain (356 rows)** is matched to the village. 255 rows carry the landmark 'CHAMPLAIN POE'; the border crossing is in the town, north of the village limit."
- [memory] on the Nov 11 rule change: "A rerun of ICE's matcher showed zero change in match rate and a slightly worse containment for ~956 rows (Fort Dix 701 at 0.68)".

### Inferences
- For ICE, folding VT/CT villages is the safe side of the same-name problem documented for New York: "swanton" (31 rows), "newtown" (9), "groton" (2) and "cambridge" (1) are ambiguous between village/borough and town, and because the place folds, the row lands on the whole town, which is correct under either reading. If these were cut out NY-style, those 43 rows would be pinned to the small village polygon (as Alden and Champlain are in NY) and the town would become a remainder cell reachable only by a string that says "town".
- The practical stake of the VT/CT decision for ICE is about 51 rows out of roughly 896,000; the decision cannot be argued from ICE accuracy either way (consistent with the memory note). The larger ICE exposure of the village rule is on the New York side (about 2,600 rows on same-name dependent villages), which is an argument about NY/MI, not about VT/CT.
- The data cost of folding for a user who wants village-level counts is the loss of 8 rows of distinct naming (Derby Line, Danielson); the village identity is still recoverable from `raw_geoid`/`raw_name`.

### Gaps
- [ice xwalk] is an uncommitted local rebuild (file shows as modified in `git status` of the ICE repo, mtime 2026-11-17 16:20, 57 minutes after `a709a91`); I assumed it was built against the `a709a91` pin in `city-match.R` because it contains `cell_share`, the "(remainder)" cells for Newtown/Killingly/Groton that only exist from `a709a91`, but I could not verify the build provenance beyond that.
- Counts are arrest rows by city string in `city-match-crosswalk.parquet` (`n_rows`); I did not open `arrests-latest.parquet` or the detention files, so row counts for other ICE tables matched to these places are not known.
- Rows that might name a VT village/CT borough but matched through tier T5 (GNIS point) or stayed unresolved (VT: 4 strings/4 rows; CT: 19 strings/26 rows unresolved) were not inspected by name.
- Whether EOIR or the slicer use the village/town distinction was out of scope and not checked.
