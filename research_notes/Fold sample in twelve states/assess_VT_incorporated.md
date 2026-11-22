# Vermont incorporated places: fold or own cell (25 sampled rows)

Assessed 17 November 2026. Per-row evidence is in `assess_VT_incorporated.csv`.

## Pattern

Verdicts: 13 fold, 7 own cell, 5 relabel only. The split follows one thing almost exactly: whether the village has a different name from its town.

- The 5 cities (Barre, Newport, South Burlington, St. Albans, Winooski) are their own county subdivisions, so folding is only a relabel.
- All 11 villages that share their town's name (Albany, Barton, Cambridge, Hyde Park, Ludlow, Manchester, Marshfield, Newfane, Swanton, Westminster, Woodstock) should stay folded. Several are substantial governments (Swanton, Barton, Hyde Park and Ludlow run electric utilities; Manchester has its own zoning and tax), but a record reading "Swanton, VT" cannot be told apart from the town and nobody outside treats them as two places.
- Of the 9 villages with a different name, 7 are distinct localities in postal and everyday usage and should be their own cells; 2 should stay folded (Derby Center, which is not a postal name and is simply the centre of Derby; Old Bennington, a 156-person historic district whose name USPS says to avoid).

All 20 sampled villages still exist as governments. None has merged or become a city since 2020.

## Rows where the verdict disagrees with the current treatment (all currently folded, verdict own cell)

| Village | Town | Confidence | Reason |
|---|---|---|---|
| Bellows Falls | Rockingham | high | Postal name for ZIP 05101, "Rockingham" is a name to avoid; own police department covering the village only; largest village in the state. |
| Orleans | Barton | high | Own ZIP 05860 and post office; renamed from Barton Landing in 1908 to stop confusion with Barton village; own electric, water, sewer, fire, school; separate settlement larger than Barton village. |
| Derby Line | Derby | medium | Own ZIP 05830; border village contiguous with Stanstead, Quebec; own water/sewer and highway district. Small (687). |
| North Troy | Troy | medium | Own ZIP 05859 (Troy is 05868); own fire, water, wastewater, library; voters rejected merger with the town twice in 2026. Small (631). |
| Saxtons River | Rockingham | medium | Own ZIP 05154 and post office; separate settlement west of Bellows Falls; Vermont Academy. Little found on what the trustees do. |
| Enosburg Falls | Enosburgh | medium | Only postal name for the whole town ("Enosburgh" is not a USPS name); village runs electric, water, wastewater, zoning. Caveat below. |
| Morrisville | Morristown | medium | Postal primary for the whole town and the county's commercial centre. Village government is essentially Morrisville Water & Light; police is the town's. Caveat below. |

Caveat for Enosburg Falls and Morrisville: their ZIP covers the entire town, so an address string with the village name does not show the person was inside the village line. If the cell is meant to answer "which name would people recognise", own cell is right; if it is meant to locate an address string, folding and mapping the village name to the town is equally defensible, as long as the lookup maps "Enosburg Falls" and "Morrisville" to the town cell. The same point applies more weakly to Bellows Falls (05101 covers the rest of Rockingham outside Saxtons River).

## Surprising or worth knowing

- North Troy: a Plan of Merger with the Town of Troy (effective 1 July 2027) was put to voters and failed twice, the second time on 9 November 2026 (186-166 and 177-158 against). The village continues for now; revisit if a third vote passes.
- Woodstock: the shared municipal manager asked both boards in September 2025 to consider merging; a Town/Village Analysis Committee is meeting this month. No vote scheduled. Does not change the verdict (same name).
- Barton Village voters refused to sell their electric department in 2022; no merger talk found there.
- Derby Center is a Census and charter name only: no ZIP uses it and the town's own offices in the village give their address as Derby.
- Manchester village is split between the Manchester (05254) and Manchester Center (05255) ZIPs; "Manchester Village" is a name USPS says to avoid.
- 24 percent of Saxtons River village residents are in the Bellows Falls ZIP 05101 according to the sample file, which looks like a ZCTA boundary artefact rather than real usage.
- Barre, St. Albans and Newport cities each have a separate same-named town next door sharing the postal name; that is a name-matching issue, not a fold issue.

## What I could not check

- The web search allowance for the session ran out after seven searches (it is shared with the other agents), so most rows rest on directly fetched pages (Wikipedia, municipal websites, one news article, one plan of merger) rather than searches. News datelines, real-estate listings and Google Maps or OpenStreetMap labels were not checked for any row.
- No live USPS confirmations: the USPS lookup page returns only an empty form to a plain fetch. All postal evidence is from the precomputed mirror in the sample file and the earlier background notes.
- Current trustee activity was not found for Albany, Cambridge, Marshfield, Newfane and Westminster villages (town websites were silent, unreachable or blocked). Their existence rests on Wikipedia's list of current villages and, for Cambridge, its charter still being in statute. All five share the town's name, so the verdict does not depend on it.
- Morristown's website returned 403 and Old Bennington's 2025 roads vote article did not resolve; those details come from search-result snippets and are marked "(snippet)" in the CSV.
- Which body runs the Swanton police was not confirmed on the municipal site; the earlier background note classed it as village-run with the FBI counting the whole town.
- South Burlington city had no web lookup at all (treated as relabel only from its class code).
