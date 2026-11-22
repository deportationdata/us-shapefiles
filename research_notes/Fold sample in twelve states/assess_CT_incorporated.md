# Connecticut incorporated places: fold or own cell (25 sampled)

Research date: 17 November 2026. Row-level evidence and sources are in `assess_CT_incorporated.csv`.

## Pattern

Sixteen of the 25 are relabels with no real choice: fourteen cities consolidated and coextensive with a town of the same name (Ansonia, Bridgeport, Bristol, Danbury, Derby, Meriden, Middletown, New Britain, New London, Shelton, Stamford, Torrington, Waterbury, West Haven), the consolidated borough-town of Naugatuck, and "Milford city (balance)", a Census remainder of the consolidated City of Milford. The nine real cases split by name. Where the dependent place shares its town's name (City of Groton, Newtown borough, Stonington borough) or has a name the post office rejects (Fenwick, Groton Long Point, Woodmont), folding matches how the place is referred to: verdict fold, 6 rows. Where the borough has its own name and that name is the USPS primary name (Danielson, Jewett City, Bantam), the borough name is what addresses, news and residents use, and the verdict is own cell: 3 rows, all disagreeing with the current blanket fold.

Counts: relabel only 16, fold 6, own cell 3. Agree with current treatment 22, disagree 3.

## Disagreements with current treatment

- **Danielson borough (Killingly), 4,155.** Own cell, medium confidence. USPS primary name for 06239 is Danielson, Killingly only acceptable, and Killingly is the primary name of no ZIP. News coverage of the 2026 fire-department dispute names Danielson. The borough council still operates, mainly to run the fire department.
- **Jewett City borough (Griswold), 3,328.** Own cell, medium confidence. USPS primary name for 06351 is Jewett City; the borough owns an electric and wastewater utility; the town's own website lists local organisations at Jewett City addresses. Griswold is in real use too (schools, town hall).
- **Bantam borough (Litchfield), 720.** Own cell, low confidence. Its ZIP 06750 has Bantam as the only name; Litchfield is not accepted for it. It has a working warden and burgesses with their own planning and zoning. The case rests mostly on consistency: a differently named CDP is already its own cell, and Bantam is at least as distinct. It is very small and residents are also plainly in Litchfield.

Caveat that applies to all three: the postal name covers more than the borough (06351 serves all of Griswold and part of Lisbon; 06239 serves much of Killingly). A city string "Danielson" or "Jewett City" therefore does not show the address is inside the borough boundary. If the purpose is name matching, an alias from the borough name to the town cell gives the same practical result as the fold; the own-cell verdict is about which name is reported.

## Surprising or worth knowing

- **City of Groton** has the fullest government of any dependent place in the state (mayor and council, paid police and fire, public works, zoning, Groton Utilities), and the FBI carves it out of the town. It is still a fold, at medium confidence, only because it shares the name Groton and the ZIP 06340 with the town, so name-based matching cannot separate them. If cells are ever assigned by coordinates rather than names, this is the one to revisit.
- **Groton Long Point** is not a borough in Connecticut law. It is a 1921 special-act association with its own police, fire and water departments and zoning. It writes its own address as "Groton Long Point, CT 06340" although USPS lists that name as one to avoid. The domain grotonlongpoint.com is parked; the Association's site is glpct.org.
- **Woodmont** hall also prints "Woodmont, CT 06460", a name that appears in no USPS list.
- **Fenwick** uses an Old Saybrook mailing address for its own borough office.
- **Milford city (balance)**: Wikipedia's Milford article gives 50,558 as the city's 2020 population, which is the Census balance figure excluding Woodmont.
- **Danielson**: in 2026 more than half of the volunteer fire department resigned in a dispute with the borough council over hiring a chief (search-result summaries only). The borough's police department was disbanded in 1987.
- No recent mergers, dissolutions or status changes were found for any of the 25.

## Not checked

- **Live USPS tool: zero rows confirmed in this run.** The lookup page is a dynamic form that returned no results through WebFetch. All postal evidence is from the precomputed mirror; 06239 (Danielson) and 06351 (Jewett City) were confirmed live in the earlier background note, not here.
- **Web search budget ran out after five searches** (Danielson, Jewett City, Bantam, Fenwick, City of Groton). Searches for Groton Long Point, Newtown borough, Stonington borough and Woodmont were not performed; those rows rest on Wikipedia, official sites fetched directly and the background notes.
- Pages that could not be read: boroughofdanielson.org (403), newtown-ct.gov borough page (403), The Day's 2015 Killingly/Danielson identity article and its "Two Grotons" piece (headline only, no body), City of Milford site (unreachable), Fenwick "about" page (404; home page read instead), Stonington borough's .gov site (not fetched; the merchants' site was read).
- Local news datelines, real-estate listings and map labels were not checked systematically for any row.
- The fourteen consolidated cities were confirmed from Wikipedia's list of Connecticut municipalities and its Borough (Connecticut) article, with an individual article read only for Derby, Meriden, Middletown and New London. The Derby article does not state coextensiveness in so many words.
- What the Newtown and Stonington borough governments do today beyond zoning was not established from a primary source.
- How far ZIP 06750 (Bantam) extends beyond the borough was not measured.
