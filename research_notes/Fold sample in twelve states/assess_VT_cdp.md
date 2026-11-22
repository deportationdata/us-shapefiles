# Vermont CDPs: fold or own cell (25 sampled)

## Pattern

Vermont CDPs are almost all village centres of a town. The 13 that carry the town's own name (Bennington, Bradford, Brattleboro, Cavendish, Fair Haven, Fairlee, Londonderry, Pawlet, Randolph, Readsboro, Sutton, Waitsfield, Wells) are plainly the town's main or central village and should fold, as they do now. The other 12 split on one signal: whether the village has its own post office whose name is the recommended USPS name for the ZIP its residents live in. Where it does and the village is physically separate from the town centre (Beecher Falls, Gilman, Greensboro Bend, North Hartland, North Springfield), addresses there carry the village name and an own cell is defensible. Where it does not (Hanksville, East Poultney, Hartford Village, Jericho Center, Underhill Flats), the village name is not something anyone would write as a city, and it should fold. Two "Center" villages have their own primary USPS name yet still belong with the town: Lyndon Center (the centre village of Lyndon) and Newport Center (the everyday name of the whole town of Newport).

Counts: fold 20, own cell 5, relabel only 0, unclear 0. Agrees with current treatment: 22 of 25.

## Disagreements with the current treatment

- **East Poultney CDP** (currently own cell, verdict fold, medium confidence). Residents' ZIP is 05764, primary name Poultney, and East Poultney is not an acceptable name for it. It is the original centre of the town of Poultney, a historic-district village of 288 people. The input flags East Poultney as a primary USPS name somewhere in Vermont, presumably a PO-box ZIP, which is the main argument the other way.
- **Hanksville CDP** (currently own cell, verdict fold, high confidence). Not a USPS name at all, 62 residents, one of three hamlets of Huntington; all addresses read Huntington.
- **Underhill Flats CDP** (currently own cell, verdict fold, medium confidence). USPS lists "Underhill Flats" as a name to avoid; residents write Jericho or Underhill depending on the side of the town line. See the straddle note below.

## Surprising or worth a look

- **Underhill Flats straddle.** 63% of residents are in Jericho, 37% in Underhill, but the name, the Underhill post office (05489) and the fire station are on the Underhill side, and Jericho calls its half Riverside. Folding the whole CDP into the plurality town (Jericho) would put a place named Underhill into Jericho. Splitting it along the town line is the only fold that matches usage.
- **Newport Center.** Wikipedia's town article says the town is "referred to by the United States Postal Service and the media as Newport Center". The fold is right, but a cell displayed as "Newport town" will be confused with the City of Newport; "Newport Center" should at least resolve to the town cell, and bare "Newport" should not.
- **Hartford Village.** Folding is right, but mail for its residents says White River Junction (05001), and Hartford is not even an acceptable USPS name for that ZIP. The town hall itself is addressed White River Junction.
- **Jericho Center CDP has 2020 population 0** in the input (share shown as NaN), so it appears to be a CDP delineated after the 2020 tabulation. Wikipedia has no article under that title.
- **Bradford** was an incorporated village until it dissolved on 1 December 2004; **Lyndon Center** gave up village status in 1962. Both are now ordinary CDPs.
- The five "own cell" verdicts are all medium confidence. Three of them (Greensboro Bend, North Hartland, North Springfield) are directional or compound forms of the town's own name; if the owner prefers a simpler rule, folding them would lose little beyond the postal name. Beecher Falls and Gilman are the two whose names share nothing with the town's.

## What I could not check

- **Web search was unavailable** for this run (the shared search budget was already used up), so evidence comes from pages fetched directly: Wikipedia articles for every place and most parent towns, plus the Hartford, Jericho, Greensboro and Huntington town websites. Local news datelines, real-estate and business listings, and map labels were not checked for any row; these are marked "not found (search unavailable)" in the CSV.
- **No live USPS confirmations.** The USPS lookup page is a script-driven form and returned no results when fetched. All postal evidence is from the precomputed `zips` column.
- Which ZIP makes East Poultney a primary USPS name was not verified.
- The Newport town website could not be found (guessed address did not resolve).
- The same-name CDPs got one lookup each (their Wikipedia article); former incorporated-village status for Bennington, Randolph and Readsboro was not stated there and was not pursued.
