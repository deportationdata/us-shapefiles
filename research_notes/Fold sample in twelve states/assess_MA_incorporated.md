# Massachusetts incorporated places (25 rows)

## Summary

All 25 are `relabel only`, all agree with the current treatment, all high confidence. In every case the Census place and the same-named county subdivision have the same ANSI code and identical land and water area in the 2024 gazetteer, the county subdivision is functional status F (a placeholder for the active city), and Wikipedia describes a single city government. No place and county subdivision differ in territory.

## Disagreements with current treatment

None.

## Oddities worth knowing

- **"Town city" Census names (5 of 25):** Barnstable Town city, Bridgewater Town city, Franklin Town city, Palmer Town city, Winthrop Town city. These are legally cities that keep "Town of X" as their official style (Wikipedia counts 13 such municipalities statewide). "X Town" is not a USPS name and nobody says it; the cell should display and match as plain Barnstable, Bridgewater, Franklin, Palmer, Winthrop.
- **Former "Town city" names:** Amesbury was styled "Town of Amesbury" from 1996 until a 2011 charter amendment (effective March 2012) made it the City of Amesbury; Easthampton adopted a city charter in 1996 and also kept "Town" for a time. Both are now plain "X city" in Census names.
- **Recent charter changes:** Bridgewater (city status 2010 per Wikipedia; previously a CDP inside the town), Winthrop (2006), Palmer (2004), Everett (2011 charter, unicameral council from 2013; internal only). None changes territory.
- **Cities whose residents mostly do not use the city name as postal city:**
  - Barnstable: none of the listed ZIPs (93% of residents) is "Barnstable"; they are Hyannis, Centerville, Marstons Mills, Cotuit, Osterville, West Barnstable. Under the current CDP rule, village CDPs that do not carry the town's name stay their own cells, so the Barnstable cell is the remainder after those are removed. That is a CDP-rule question, not a problem with this relabel.
  - Boston: the listed ZIPs (43% of residents) are all neighbourhood names (Dorchester, Dorchester Center, Brighton, East Boston, Jamaica Plain, South Boston, Hyde Park) with Boston acceptable. Free-text strings like "Dorchester, MA" or "East Boston, MA" need to resolve to Boston.
  - Newton: village names are primary for most ZIPs (Newton Center, West Newton, Newtonville, Chestnut Hill, Auburndale, Newton Highlands, Waban). Chestnut Hill also extends into Boston and Brookline.
  - Northampton: Florence (37%) and Leeds (7%). Palmer: Three Rivers, Bondsville, Thorndike (34% together). Taunton: East Taunton (12%). Springfield: Indian Orchard (6%).
- **Spelling:** USPS says to avoid "Marlboro" for Marlborough, though it is a common variant.

## Method

One mechanical check and one text lookup per place, for every row:

- **Census 2024 gazetteer** (place file and county subdivision file for the state): the place and the same-coded county subdivision were compared on ANSI code, land area and water area.
- **Wikipedia** article introduction for each city (full article for the few noted below).
- USPS evidence is from the precomputed `zips` column only (it lists ZIPs holding roughly 5% or more of residents).

## Could not check

- No live USPS confirmations: the lookup tool needs a form submission that WebFetch cannot make, and a scripted request was blocked.
- Web search was unavailable (shared search budget exhausted), so no municipal websites, news datelines or listings were consulted; local-usage evidence is Wikipedia only.
- Charter and government details are as Wikipedia states them, not checked against the municipalities' own sites.
