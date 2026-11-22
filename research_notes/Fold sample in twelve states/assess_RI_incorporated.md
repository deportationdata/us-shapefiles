# Rhode Island incorporated places (8 rows)

## Summary

The sample is all 8 Rhode Island cities. All are `relabel only`, all agree with the current treatment, all high confidence. Each city has the same ANSI code and identical land and water area as its same-named county subdivision in the 2024 gazetteer (county subdivision functional status F), and Wikipedia describes each as a single city. No place and county subdivision differ in territory.

## Disagreements with current treatment

None.

## Oddities worth knowing

- **East Providence:** fewer than half of residents have "East Providence" as their recommended postal city. Riverside (ZIP 02915, 35%) and Rumford (02916, 18%) are sections of the city with their own primary postal names and no governments; strings saying "Riverside, RI" or "Rumford, RI" need to resolve to East Providence.
- **Warwick:** Potowomut is a semi-exclave reachable by land only through East Greenwich and uses East Greenwich addresses; ZIP 02818 (7% of Warwick residents) has East Greenwich as its primary name. An address-based "East Greenwich, RI" string can therefore be a Warwick location. Warwick also has about 30 named villages (Apponaug, Conimicut, Cowesett, Pawtuxet and others), none with a government.
- **Cranston:** the eastern part (ZIP 02905, 12% of residents; Edgewood area) has Providence as its primary postal name with Cranston acceptable. Pawtuxet Village straddles Cranston and Warwick.
- **Providence:** ZIPs 02904/02908 extend into North Providence and 02905/02907 into Cranston.
- **Central Falls** went through state receivership (2010) and bankruptcy (2011 to 2012) but remains a functioning city.

## Method

One mechanical check and one text lookup per place, for every row:

- **Census 2024 gazetteer** (place file and county subdivision file for the state): the place and the same-coded county subdivision were compared on ANSI code, land area and water area.
- **Wikipedia** article introduction for each city (full article for the few noted below).
- USPS evidence is from the precomputed `zips` column only (it lists ZIPs holding roughly 5% or more of residents).

## Could not check

- No live USPS confirmations: the lookup tool needs a form submission that WebFetch cannot make, and a scripted request was blocked.
- Web search was unavailable (shared search budget exhausted), so no municipal websites, news datelines or listings were consulted; local-usage evidence is Wikipedia only.
- Charter and government details are as Wikipedia states them, not checked against the municipalities' own sites.
