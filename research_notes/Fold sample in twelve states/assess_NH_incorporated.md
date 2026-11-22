# New Hampshire incorporated places (13 rows)

## Summary

The sample is all 13 New Hampshire cities. All are `relabel only`, all agree with the current treatment, all high confidence. Each city has the same ANSI code and identical land and water area as its same-named county subdivision in the 2024 gazetteer (county subdivision functional status F), and Wikipedia describes each as a single city. No place and county subdivision differ in territory.

## Disagreements with current treatment

None.

## Oddities worth knowing

- **Lebanon:** West Lebanon (ZIP 03784, 31% of residents) has its own primary postal name and is commonly used as a locality name; it is a section of the city with no government, so strings saying "West Lebanon, NH" need to resolve to Lebanon.
- **Villages inside cities with no postal primacy:** Penacook, East Concord, West Concord, Concord Heights (Concord); Lakeport and Weirs Beach (Laconia; both names USPS says to avoid); East Rochester, Gonic, North Rochester (Rochester); West Franklin (Franklin); Cascade (Berlin).
- **City ZIPs that also serve neighbouring towns:** Concord 03303 (Boscawen, Webster), Keene 03431 (Roxbury, Surry, North Swanzey), Portsmouth 03801 (Newington). "Unity" is a to-avoid name on Claremont's ZIP and "Pinardville" (in Goffstown) on Manchester's 03102.
- No recent charter or status changes were found.

## Method

One mechanical check and one text lookup per place, for every row:

- **Census 2024 gazetteer** (place file and county subdivision file for the state): the place and the same-coded county subdivision were compared on ANSI code, land area and water area.
- **Wikipedia** article introduction for each city (full article for the few noted below).
- USPS evidence is from the precomputed `zips` column only (it lists ZIPs holding roughly 5% or more of residents).

## Could not check

- No live USPS confirmations: the lookup tool needs a form submission that WebFetch cannot make, and a scripted request was blocked.
- Web search was unavailable (shared search budget exhausted), so no municipal websites, news datelines or listings were consulted; local-usage evidence is Wikipedia only.
- Charter and government details are as Wikipedia states them, not checked against the municipalities' own sites.
