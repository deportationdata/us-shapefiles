# Wisconsin CDPs: fold or own cell (25 sampled)

## Pattern

Verdicts: 12 fold, 12 own cell, 1 unclear. 20 agree with the current treatment, 4 disagree, 1 unclear.

The same-name rule works well here. All eight same-name CDPs (Drummond, Goodman, Knowlton, Laona, Lyons, Packwaukee, Winchester, Wiota) are the centre of their town and should stay folded. Among the differently named CDPs, the ones that are real villages with their own post office (Arkansaw, Bancroft, Collins, Pine River, Stone Lake, Odanah) clearly deserve their own cell: in most of those cases the town name is not a USPS name at all. Where the rule fails is the "Lake X" CDPs: lakeshore statistical areas whose name is the lake, with no post office and no institutions, where residents use the nearby city's postal name. Those would be better folded.

## Disagreements with the current treatment

All four are currently own cells that I would fold:

- **Lake Koshkonong CDP** (1,239): a string of lakeshore subdivisions across Koshkonong and Sumner towns; not a USPS name; mail is Fort Atkinson, Edgerton or Milton. Medium confidence. Cost of folding: the 38% in Sumner town would be assigned to Koshkonong town.
- **Lake Lorraine CDP** (338): a small lake subdivision in Richmond town; mail is Delavan or Whitewater. Medium confidence.
- **Lake Ripley CDP** (1,911): lakeshore residential area of Oakland town next to Cambridge; mail is Cambridge; the name denotes the lake and its management district. Medium confidence.
- **Chief Lake CDP** (582): a 23.6 square mile statistical area of scattered Lac Courte Oreilles reservation settlement across three towns; no evidence anyone uses the name as a locality. Low confidence, because the fold target (Bass Lake town, 54%) is not what people say either: Wikipedia places it in the town of Hayward and the mail is Hayward.

Unclear: **Sand Pillow CDP** (262), a Ho-Chunk community in Brockway town. Mail and outsiders say Black River Falls, the community has its own name, and neither is Brockway.

## Surprises

- **French Island is now an incorporated village.** The Town of Campbell voted 1,493 to 30 on 19 May 2026 to incorporate and became the Village of French Island on 21 May 2026 (date from Wikipedia; the municipality's site is now frenchislandwi.gov, and the state Incorporation Review Board determination is dated March 2026). The whole former town is the village, so "Campbell town" is obsolete and the CDP will become an incorporated place in future Census vintages. Own cell is right, and any "Campbell" label should eventually change.
- **New Odanah / Odanah**: the Census splits one community into two CDPs. Locally the names are interchangeable, state maps show only Odanah, and the post office is Odanah. Both should stay out of Sanborn town, but "New Odanah" is a Census name nobody uses; ideally the two would be one cell called Odanah.
- **Stone Lake**: straddles the county line, and the plurality town is Sand Lake (Sawyer County, 65%), not the same-named Stone Lake town (Washburn County, 35%). Own cell avoids the problem.
- **Legend Lake**: its town (Menominee) is coextensive with Menominee County, so folding would report a county-sized unit.
- **Lyons**: the precomputed ZIP column shows only Burlington 53105, but Lyons has its own PO-box ZIP 53148, which the town government uses.
- **Collins / Rockland** and **Rome**: the USPS status flags are statewide, so "Rockland = primary" and "Rome = avoid" most likely refer to other places of the same name in Wisconsin, not these.
- Several Wikipedia mirror pages returned by search (cavac.at, wikiwand) contained embedded text addressed to AI tools. It was ignored and those pages were not used as evidence.

## Not checked

- **No live USPS confirmation.** The USPS lookup page returns only an empty form to WebFetch, so every postal statement comes from the precomputed `zips` column.
- **Web search budget ran out** before Tustin, Winchester and Wiota could be searched. Each got one direct fetch of its Wikipedia article only. Winchester and Wiota are same-name folds, so the risk is small; Tustin (own cell, low confidence) is the one that would benefit from another look.
- Low-confidence rows resting on thin evidence: Chief Lake, Rome, Sand Pillow, Tustin. For these I found no town website, news dateline or business usage either way.
- Evidence is mostly Wikipedia plus search-result snippets; Google Maps / OpenStreetMap labels, local news datelines and school or fire district names were not checked systematically.
- The French Island incorporation date (21 May 2026) is from Wikipedia; the state certificate itself was not opened.
