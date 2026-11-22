# New Jersey incorporated places: fold sample assessment (25 rows)

**Pattern.** All 25 are `relabel only`, all agree with the current treatment. Every sampled borough, city, town and village is classfp C5 and appears in the county-subdivision file as its own subdivision with identical population, so no township contains any of them and the "fold" changes only the label. None straddles a county line, and none has merged or dissolved (the recent New Jersey consolidations, such as Princeton in 2013 and Pine Valley into Pine Hill in 2022, are not in this sample).

**Disagreements with current treatment.** None.

## Flags

- **Same-named borough/township pair: Clinton.** Clinton town (2,773) and the separate Clinton Township (13,505), both in Hunterdon County. "Clinton, NJ" is the town's post office name (08809) and a reader most likely means the town, but the township is five times bigger and parts of it carry Clinton addresses. It is the only same-name pair among the 25.
- **Postal name belongs to another municipality.**
  - Loch Arbour village (224): mail goes as Allenhurst 07711.
  - North Caldwell borough (6,694): mail goes as Caldwell 07006.
  - North Plainfield borough (22,808): mail goes as Plainfield, a different city in a different county (Union, not Somerset).
  - Tinton Falls borough (19,181): no primary ZIP of its own; residents split across Eatontown (46%), Neptune (34%) and Asbury Park (18%).
  - Mount Arlington borough: 20% of residents are in the Landing ZIP (a Roxbury Township name).
- **Postal name reaches beyond the municipality** (so the name over-attracts): Allenhurst (covers Loch Arbour), Branchville (Sandyston), Califon (Tewksbury Township), Salem (Mannington), Perth Amboy (Hopelawn, in Woodbridge), Camden 08104 (Haddon Township), Woodbury Heights and Woodcliff Lake (Woodbury and Westwood listed as acceptable names).
- **Tiny municipality with merger history: Loch Arbour.** Fifth-smallest in the state. Voters rejected rejoining Ocean Township in 1997, and a merger with Allenhurst was discussed in 2011-2012; neither happened. Still governed by its own three-member board of commissioners.
- **Merger studied, not done: Mount Arlington.** A consolidation study commission with Roxbury was formed in 2015; Mount Arlington is still a separate borough.
- Allenhurst (472) and Longport (893) are small shore boroughs but ordinary functioning municipalities.

## What I could not check

- The web search budget for this run was exhausted (shared with other agents) before any search went through, so the per-place lookup is the Wikipedia article (fetched for all 25 places, full article for the flagged ones) plus the repository's own county-subdivision and 2020 block-population files. No municipal websites, news datelines or map labels were opened.
- USPS evidence is from the precomputed `zips` column only. The live USPS tool is a form that WebFetch could not submit, so nothing was confirmed live.
- Whether the smallest governments are actually meeting was not independently confirmed; Census lists all 25 as active (funcstat A).
