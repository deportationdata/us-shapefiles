# Maine incorporated places (23 rows)

## Summary

All 23 are `relabel only`, all agree with the current treatment, all high confidence. Each city has the same ANSI code and identical land and water area as its same-named county subdivision in the 2024 gazetteer (county subdivision functional status F), and Wikipedia describes each as a single city. No place and county subdivision differ in territory.

## Disagreements with current treatment

None.

## Oddities worth knowing

- **Sanford** became a city only on 1 January 2013 (charter approved November 2012; previously a town with town meeting). It includes the village of Springvale, which has its own ZIP (04083, 21% of residents) and primary postal name.
- **Gardiner:** South Gardiner (04359, 8% of residents) has its own primary postal name.
- **Old Town:** "Town" is part of the name, not a status suffix. ZIP 04468 also carries "Indian Island", which is the Penobscot reservation, a separate county subdivision.
- **City ZIPs that also serve neighbouring towns** (the city name is the mailing name for people who live in another municipality): Ellsworth (Lamoine, Trenton, Otis, Mariaville, Amherst, Osborn, Waltham, Fletchers Landing Twp), Augusta (Chelsea, Sidney), Bangor (Glenburn, Hermon, Veazie), Bath (Arrowsic, West Bath), Belfast (Swanville, Waldo), Biddeford (Dayton), Caribou (Connor Twp, Woodland), Waterville (Benton, Winslow), Gardiner (Pittston, West Gardiner). This affects free-text matching (an "Ellsworth, ME" string may be a Lamoine resident) but not the fold decision.
- **South Portland:** "Portland" is an acceptable postal name for ZIP 04106, so some South Portland addresses are written as Portland.
- **Small cities:** Eastport (1,288) and Hallowell (2,570) are full cities despite their size.

## Method

One mechanical check and one text lookup per place, for every row:

- **Census 2024 gazetteer** (place file and county subdivision file for the state): the place and the same-coded county subdivision were compared on ANSI code, land area and water area.
- **Wikipedia** article introduction for each city (full article for the few noted below).
- USPS evidence is from the precomputed `zips` column only (it lists ZIPs holding roughly 5% or more of residents).

## Could not check

- No live USPS confirmations: the lookup tool needs a form submission that WebFetch cannot make, and a scripted request was blocked.
- Web search was unavailable (shared search budget exhausted), so no municipal websites, news datelines or listings were consulted; local-usage evidence is Wikipedia only.
- Charter and government details are as Wikipedia states them, not checked against the municipalities' own sites.
- Portland's island neighbourhoods (e.g. Peaks Island) were not examined; they fall below the share threshold in the `zips` column.
