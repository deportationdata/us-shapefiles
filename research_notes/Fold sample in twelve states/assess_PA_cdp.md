# Pennsylvania CDPs: fold or own cell (25 sampled)

Verdicts: 12 own cell, 12 fold, 1 unclear. All 25 are currently "own cell", so 12 disagree with the current treatment.

## Pattern

Pennsylvania CDPs split cleanly on whether the name has a post office. Where the CDP name is the USPS primary name of a ZIP (usually an old coal patch town or the main village of a rural township), people, addresses and local sources use the village name and the township name is generic or even discouraged by USPS: these should stay their own cells. Where the CDP name is not a USPS name or is on the avoid list, it is usually a campus, a lake colony, a subdivision-style suburb, a Census compound, or a hamlet whose residents write the neighbouring borough's name: these read as folds. The catch for the folds is that the name people actually use is often an adjacent borough (Kutztown, Lewistown, Duncansville, Fayette City, Fleetwood, Philipsburg, Mohnton), not the township, so folding into the township is "least wrong" rather than what people say.

## Disagreements with current treatment (all currently own cell, verdict fold)

- **Alleghenyville** (Brecknock twp), low confidence: USPS avoid name; mail says Mohnton; minor village name.
- **Beurys Lake** (Barry twp): private lake colony of 132, not a USPS name.
- **Bressler** (Swatara twp): neighbourhood of a large suburban township; one of several acceptable names in a Harrisburg ZIP.
- **Foot of Ten** (Allegheny twp): not a USPS name; described as a part of greater Duncansville.
- **Highland Park** (Derry twp): suburb on the edge of Lewistown; not a postal name there, and the name collides with the better-known Pittsburgh neighbourhood.
- **Homeacre-Lyndora** (Butler twp): Census compound nobody uses; 84% of residents write Butler. Lyndora alone is a real postal name (16045) and should still resolve to Butler Township.
- **Kutztown University** (Maxatawny twp): campus.
- **Misericordia University** (Dallas twp): campus; everyone says Dallas.
- **Naomi** (Washington twp): hamlet of 53, not a USPS name; mail says Fayette City.
- **South Philipsburg** (Rush twp), low confidence: former borough, not a USPS name; would be read as Philipsburg.
- **Walnuttown** (Richmond twp): USPS avoid name; western edge of Fleetwood.
- **Weigelstown** (Dover twp): 15,136 residents but no postal standing; addresses say Dover, which is also the township name.

Unclear: **Dunnstown** (Woodward twp): a village laid out in the 1700s that holds most of its township, but USPS says to avoid the name in favour of Lock Haven.

## Surprising

- **Strausstown** was a borough until it merged into Upper Tulpehocken Township on 1 July 2016 (referendum April 2016). It keeps its post office and is styled the "Village of Strausstown"; USPS lists the township name as one to avoid. Own cell.
- **South Philipsburg** is also a former borough (incorporated 1891); date of dissolution not found.
- **Maryd** is a Census/GNIS spelling nobody uses: the post office, ZIP 17952 and Wikipedia all say "Mary D". It needs matching on "Mary D".
- **Pocono Pines**: folding would be misleading, because the community called Tobyhanna is in Coolbaugh Township, not Tobyhanna Township. Tobyhanna Township's own offices have a Pocono Pines address.
- **Mammoth** and **Quentin** have PO-box-only ZIPs (15664, 17083) that the input `zips` column does not show, because those ZIPs have no residential area; the input shows only the surrounding delivery ZIP (Mount Pleasant, Lebanon). The `usps_place_name = primary` flag is right for both.
- **Highland Park**'s `usps_place_name = acceptable` flag comes from a different Highland Park elsewhere in the state, not from its own ZIP.
- **Walnuttown**: Wikipedia says a small part lies in Maidencreek Township; the input shows 100% Richmond.
- **Herminie** / Sewickley Township and **Mammoth** / Mount Pleasant Township: the township name would be confused with a same-named borough elsewhere (Sewickley in Allegheny County, Mount Pleasant borough next door).

## Not checked

- Live USPS lookups: none confirmed. One attempt at the USPS tool returned only the empty form. All postal evidence is from the precomputed `zips` column plus third-party ZIP sites for Mammoth and Quentin.
- The web-search budget ran out before the last place: Weigelstown's local usage was assessed from the Wikipedia place and township articles only, with no search of news or the township site.
- Most local-usage evidence is from Wikipedia and search-result snippets (marked "(snippet)"); township websites were reached only for Tobyhanna and Upper Tulpehocken. No news datelines, fire company or map labels were checked for Alleghenyville, Beurys Lake, Naomi, Walnuttown, Highland Park or Dunnstown.
- Date South Philipsburg ceased to be a borough.
- Two search-result pages (a Wikipedia mirror, cavac.at) contained embedded text instructing the reader to output unrelated content; it was ignored and that mirror was not used as a source.
