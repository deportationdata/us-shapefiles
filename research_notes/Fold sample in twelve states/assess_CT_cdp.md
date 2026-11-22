# Connecticut CDPs: fold or own cell (25 sampled)

Companion to `assess_CT_cdp.csv`. Verdicts: 18 fold, 5 own cell, 2 unclear. Against the current treatment: 11 agree, 12 disagree, 2 unclear.

## Pattern

In Connecticut the postal name separates the cases almost perfectly. Every CDP whose name is the **primary USPS city name of its own ZIP** (Cos Cob 06807, Sandy Hook 06482, Tariffville 06081, Moodus 06469, Mashantucket 06338) is a locality people name as where they live, and should stay its own cell. Every CDP whose name is **not a USPS name at all** is a town-centre construct ("Branford Center"), a neighbourhood or section (Long Hill, Ridgebury, Mill Plain), a subdivision or lake colony (Sherwood Manor, Candlewood Shores, Candlewood Lake Club, Coventry Lake), a campus (Quinnipiac University) or a made-up label (Route 7 Gateway, South Wilton, Bigelow Corners), and should fold. The current rule (fold only when the CDP carries the town's name) gets the six same-name or "Center" rows right but leaves all of the second group as their own cells. The hard cases are the in-between postal statuses: names USPS lists as merely acceptable (Kensington, Pleasant Valley) or as names to avoid (Hazardville). A rule of "own cell only if the CDP name differs from the town's and is the primary USPS city name of a ZIP covering most of its residents" would reproduce 23 of my 25 verdicts and put the other 2 (the unclear ones) on the fold side, which is the way I lean for both.

## Disagreements with current treatment (all currently "own cell", verdict fold)

| CDP | Town | Confidence | Reason |
|---|---|---|---|
| Bigelow Corners | New Fairfield | high | Crossroads name, not a USPS name, no institutions use it; CDP count swung 138 to 617 between censuses. |
| Candlewood Lake Club | New Milford (54%) / Brookfield (46%) | medium | Private club community; listings and mail use the town. Straddles two towns and two counties nearly evenly, so folding to New Milford mislabels the Brookfield half. |
| Candlewood Shores | Brookfield | medium | Lake subdivision. Has a real special taxing district (water, beach, blight ordinance) but no postal identity; everything else is Brookfield. |
| Coventry Lake | Coventry | medium | The name is the lake's; the CDP is the housing around it. Not a USPS name. |
| Long Hill | Trumbull | medium | Genuine old neighbourhood (green, fire company) but addresses are Trumbull; also collides with Long Hill CDP in Groton. |
| Mill Plain | Fairfield | high | Neighbourhood named after a road; collides with Mill Plain in Danbury. |
| Pleasant Valley | Barkhamsted | medium | Acceptable USPS name with its own post office, but it is where Barkhamsted's town hall and school are and has 161 residents; a Barkhamsted cell without it would be odd. |
| Quinnipiac University | Hamden | high | College campus; the university's own address is Hamden. |
| Ridgebury | Ridgefield | medium | Historic northern section of Ridgefield (school, church) with no postal standing. |
| Route 7 Gateway | Ridgefield | high | Invented statistical label for a highway corridor; no local use found. |
| Sherwood Manor | Enfield | high | Post-war subdivision name. |
| South Wilton | Wilton | high | Directional statistical construct. |

## Unclear (both currently "own cell", both leaning fold)

- **Hazardville (Enfield)**: USPS lists the name as one to avoid and Wikipedia calls it a section of Enfield, but it is a historic mill village with a chartered Hazardville Fire District and a well-known name that could plausibly appear in free-text city fields.
- **Kensington (Berlin)**: an acceptable USPS name with a post office called Kensington, but it holds Berlin's town hall and most of Berlin's population, and USPS prefers "Berlin". Taking Kensington out leaves a "Berlin" cell that is mostly not where Berlin's government and people are.

## Agreements

Own cell: Cos Cob, Mashantucket, Moodus, Sandy Hook, Tariffville. Fold: Branford Center, Cornwall, Greenwich, New Milford, Sharon, Weston.

## Surprising or worth knowing

- **Mashantucket** is not just a CDP: it is the Mashantucket Pequot Reservation (federal trust land, tribal government and police) and contains Foxwoods. It is the strongest own-cell case in the sample for reasons other than the postal name.
- **Candlewood Lake Club** crosses a county line (Fairfield / Litchfield) as well as a town line, at 54/46. Neither fold nor own cell is quite right; splitting at the town line would be.
- **Candlewood Shores** shows that a CDP can have a real (special-purpose) taxing district and still not be a locality anyone would name.
- **Moodus** and **Pleasant Valley** look alike (the village that holds the town offices of a differently named town) but I split them: Moodus is the sole primary name of ZIP 06469 and the town itself writes "Moodus, CT"; Pleasant Valley is only an acceptable alias of a ZIP whose preferred name is Barkhamsted. That distinction is thin, and Pleasant Valley is the least certain of the fold verdicts.
- Many of these CDPs (Cornwall, Mill Plain, Quinnipiac University, Ridgebury, Route 7 Gateway, South Wilton, Weston) were newly delineated for the 2020 census, which is why almost nothing but Census-derived aggregator pages mentions them.
- The Wikipedia infobox for Cornwall CDP gives ZIPs 06754/06796, while the precomputed column has 06753 (Cornwall) for 77% of residents. I trusted the precomputed column; it does not affect the verdict.
- The Sandy Hook post office building has closed; 06482 mail is handled from the Newtown office on Commerce Road, but the ZIP's city name is still Sandy Hook.

## Not checked

- **No live USPS confirmations.** The lookup page is a form whose results could not be retrieved with WebFetch, and a direct request to its backend was blocked by the permission system. All postal evidence is from the precomputed `zips` column.
- The shared web-search budget ran out before two follow-up searches (everyday and business use of "Hazardville" and "Kensington"), which is part of why those two are unclear.
- Much evidence is from search-result summaries rather than opened pages; these are marked "(snippet)" in the CSV. Pages actually opened: Wikipedia articles for Hazardville, Sandy Hook, Kensington, Pleasant Valley, Tariffville, Long Hill and Coventry Lake.
- Not found: any town-website page listing sections for New Fairfield, Ridgefield, Wilton, Trumbull or Coventry; news datelines for any of the small CDPs; the current status of the Kensington Fire District and the Tariffville Fire District.
