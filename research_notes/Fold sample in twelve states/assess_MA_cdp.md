# Massachusetts CDPs: fold or own cell (25 sampled)

Verdicts: fold 16, relabel only 5, own cell 4. Five of 25 disagree with the current treatment, all in the same direction (currently own cell, should fold).

## Pattern

Massachusetts CDPs fall into three groups. (1) Same-name CDPs (16 of 25) are either the whole town (Belmont, Holbrook, Hull, Saugus, Wellesley: CDP population equals the town's, so the fold is only a label) or the built-up centre of a town of the same name (Andover, Bellingham, Bourne, Boxford, Chatham, Hopkinton, Marshfield, Medfield, Pepperell, Topsfield, Walpole); the same-name rule handles all of them correctly. (2) Differently named CDPs that have their own USPS primary name and post office (Onset, Siasconset, East Sandwich, Monument Beach) are real villages that people and the post office name, and own cell is right. (3) Differently named CDPs with no USPS standing (Cedar Crest, Cordaville, Millis-Clicquot, Ocean Bluff-Brant Rock, South Ashburnham) are neighbourhoods, historic mill villages or Census compound names whose mail reads the town; these are where the current rule misfires. In this sample, "the place name is a USPS primary name for a ZIP holding some of its residents" separates groups 2 and 3 exactly.

## Disagreements with current treatment (all currently own cell, verdict fold)

- **Cedar Crest CDP** (Marshfield), high confidence: a residential neighbourhood named for a hill; not a USPS name; appears only on real-estate sites, usually as "Green Harbor-Cedar Crest".
- **Millis-Clicquot CDP** (Millis), high: a Census compound for the centre of Millis plus the Clicquot neighbourhood (named for a defunct ginger-ale company); more than half the town; nobody uses the compound.
- **Cordaville CDP** (Southborough), medium: a real village that the town website lists among its four villages, but not a USPS name; the MBTA station in it is called Southborough and addresses read Southborough.
- **Ocean Bluff-Brant Rock CDP** (Marshfield), medium: a compound of four beach neighbourhoods (Ocean Bluff, Brant Rock, Fieldston, Rexhame). The compound is never used and home delivery reads Marshfield. Brant Rock (02020) and Ocean Bluff (02065) are individually real names with PO-box ZIPs, which is the argument against folding.
- **South Ashburnham CDP** (Ashburnham), medium: USPS lists the name as one to avoid; same ZIP as the town; a historic factory village and section of Ashburnham.

## Surprising or worth knowing

- **Wellesley**: 58% of residents live in ZIP 02481, whose USPS primary name is Wellesley Hills (Wellesley is only acceptable), and 5% in 02457 Babson Park. Those strings need to resolve to Wellesley.
- **Bourne**: the town's main ZIP (02532) has USPS primary Buzzards Bay, with Bourne only acceptable. Residents of both Bourne CDP and most of Monument Beach CDP get mail addressed Buzzards Bay, which is a different village on the other side of the canal. Monument Beach is a USPS primary name only for its small ZIP 02553 (6% of the CDP's residents), so its own-cell verdict rests on village identity more than on mail.
- **Siasconset**: universally written 'Sconset or Sconset, a spelling USPS lists as one to avoid; it needs an alias.
- **Ocean Bluff-Brant Rock**: the precomputed zips column shows only 02050 Marshfield because the two village ZIPs are PO-box only and hold no residents. A 2013 USPS release said the Brant Rock post office was closing with boxes moved to Ocean Bluff; a ZIP directory page still lists it. Not resolved.
- **Onset**: has its own fire and water district with a separate district tax, the nearest thing to a village government in this sample.
- **Walpole (CDP)** on Wikipedia leads to the town article rather than a separate CDP article.
- No merged, dissolved or vanished places in this sample.

## What I could not check

- **Live USPS tool: none confirmed.** The lookup page returns only an empty form to WebFetch, and a direct request to its backend was blocked by the permission system. All postal evidence is from the precomputed `zips` column plus search snippets about post offices.
- **Search budget ran out** (shared limit) before second lookups for Monument Beach, South Ashburnham and Onset. South Ashburnham's current local usage is "not found"; Monument Beach rests on Wikipedia and one search.
- One local-blog page on Southborough's villages (mysouthborough.com) could not be opened; Cordaville's local-usage evidence is the town's own page plus snippets.
- The eleven same-name town-centre CDPs and five whole-town CDPs got one Wikipedia lookup each and no local-news check, which seemed sufficient given the identical name.
- Google Maps / OpenStreetMap labels were not checked for any row.
