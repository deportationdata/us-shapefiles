# Rhode Island CDPs: fold or own cell (25 sampled)

## Pattern

Rhode Island CDPs split cleanly on whether the village has its own post office name. Villages in the rural west and south (Ashaway, Hope Valley, Bradford, Carolina, Wyoming, Greene, Chepachet, Harrisville, Pascoag, Greenville, Wakefield / Peace Dale) are the USPS recommended city name for their ZIP, in several cases with the town name absent or explicitly "avoid" (Glocester, Smithfield), and four town governments write the village as their own city name (Glocester: Chepachet; Burrillville: Harrisville; Richmond: Wyoming; South Kingstown: Wakefield). Those are right as own cells. The CDPs that are not USPS names are a different kind of thing: sections of a suburban town (Cumberland Hill, Valley Falls), a Census construct (Newport East), a Navy housing and marina area (Melville), and beach colonies (Misquamicut, Weekapaug, Quonochontaug). Those should fold. The current rule (fold only when the CDP has the town's name) gets the three same-name CDPs and Foster Center right but leaves all of the second group as own cells.

Counts: own cell 12, fold 11, unclear 2. Agrees with current treatment 16, disagrees 7, unclear 2.

## Disagreements with current treatment (all currently own cell, verdict fold)

- **Newport East CDP** (12,337; Middletown), high confidence. Census name for the built-up part of Middletown; not a USPS name; no local use found. Keeping it hides most of Middletown under a name that suggests Newport.
- **Valley Falls CDP** (12,094; Cumberland), medium. Real historic mill village, but not a USPS name, mail is Cumberland, and the town hall (45 Broad Street) is addressed Cumberland.
- **Cumberland Hill CDP** (8,140; Cumberland), medium. Not a USPS name; no source treats it as separate from Cumberland. Together with Valley Falls it removes about 20,000 people from the Cumberland cell.
- **Melville CDP** (1,609; Middletown 75% / Portsmouth 25%), medium. Class M2 military CDP: Navy housing, part of the Naval Undersea Warfare Center, and a marina district. Not a USPS name. Straddle problem: the Melville name belongs to the Portsmouth shore but the population plurality is in Middletown.
- **Misquamicut CDP** (434; Westerly), medium. Beach resort and fire district; USPS says to avoid the name.
- **Weekapaug CDP** (467; Westerly), medium. Seaside colony; not a USPS name.
- **Quonochontaug CDP** (422; Charlestown), medium. Three beach colonies ("Quonnie"); not a USPS name.

## Unclear

- **Clayville CDP** (312; Foster 55% / Scituate 45%). USPS primary name with its own ZIP on the Scituate side, but the Foster majority is addressed Foster; tiny; folding would label the Scituate part as Foster.
- **Harmony CDP** (1,036; Glocester). Named village with a USPS primary name, but 85% of residents are in the Chepachet ZIP.

## Surprising or worth knowing

- **Wakefield-Peace Dale** is a Census compound nobody uses. The cell is right (own cell, medium) but it needs "Wakefield" and "Peace Dale" as match names; Wikipedia titles it "Wakefield-Peacedale".
- **Watch Hill** is the weakest "own cell" (low confidence): USPS says avoid the name and Wikipedia calls it a neighbourhood of Westerly, but it is nationally known by its own name. It is treated differently from Misquamicut and Weekapaug only on name recognition; a consistent rule could reasonably fold all three Westerly shore CDPs.
- **Chepachet, Harrisville, Wyoming and Wakefield are town seats** addressed under the village name. That is the "town centre" pattern that elsewhere argues for folding, but here the village name, not the town name, is what appears in addresses. Note also that the postal village is much larger than the CDP (Chepachet's ZIP covers most of Glocester; the CDP has 1,704 people), so a name match to the CDP cell overstates precision.
- **Hopkinton CDP** is locally "Hopkinton City" and was new in 2020.
- **Bradford, Carolina, Wyoming, Clayville, Hope Valley** are villages that cross town lines in reality even where the CDP does not.
- The input CSV says Hopkinton's and Richmond's town names are USPS "primary"/"acceptable" somewhere in the state; for the village ZIPs themselves the town name is often absent.

## What could not be checked

- **Web search was unavailable**: the shared search budget for the session was already exhausted, so no search-engine queries ran. Evidence comes from pages fetched directly: the Wikipedia article for every place and its town, and the town websites of Glocester, Burrillville, Cumberland, South Kingstown, Richmond and Foster. Smithfield's and Hopkinton's sites returned 403.
- Consequently not checked for any row: local news datelines, real-estate and business listings, Google Maps / OpenStreetMap labels, school and fire-district names beyond what Wikipedia states. Fire-district status of Watch Hill, Weekapaug, Quonochontaug and Cumberland Hill was not found in the pages opened.
- **No live USPS confirmation**: the USPS lookup page returns only a blank form to a plain fetch. All postal evidence is from the precomputed `zips` column.
- The medium-confidence folds for Valley Falls and Cumberland Hill, and the two unclear rows, are the ones most worth a second look with search available.
