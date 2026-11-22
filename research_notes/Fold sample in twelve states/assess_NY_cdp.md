# New York CDPs: fold or own cell (25 sampled)

## Pattern

New York CDPs are almost all town-recognised hamlets, and the current rule (fold only when the CDP carries its town's name) matches reality for 22 of 25. Where the hamlet has its own post office and USPS primary name (Congers, Mahopac, Oceanside, Nesconset, Locust Valley, Roslyn Heights, Mastic Beach, Peconic, Barneveld, Limestone, Mineville, Niverville, Salisbury Mills, South Cairo, Wells Bridge, North Blenheim), it is the name people write and the town name is often not a postal name at all (Trenton, Carrollton, Blenheim, North Hempstead) or one USPS says to avoid (Clarkstown). The same-name CDPs (Cherry Creek, Clarence, Henderson) are the town's central hamlet and fold cleanly; Brighton CDP is the whole town. The rule's weak spot is small hamlets whose name is not a USPS name: those are neighbourhood or lake-community labels and would be better folded.

Counts: own cell 17, fold 7, relabel only 1, unclear 0.

## Disagreements with current treatment (3)

- **Balmville CDP** (Newburgh town; currently own cell, verdict fold, medium). USPS lists Balmville as a name to avoid for 12550; all mail reads Newburgh. It is one of about thirteen hamlets/neighbourhoods of the Town of Newburgh, directly north of the city. Caveat: "Newburgh" in free text usually means the city.
- **Duane Lake CDP** (Duanesburg town; currently own cell, verdict fold, medium). Not a USPS name; a 329-resident community around a man-made lake; mail reads Duanesburg.
- **Upper Red Hook CDP** (Red Hook town; currently own cell, verdict fold, medium). Not a USPS name; 180 residents; a CDP only since 2020; mail reads Red Hook. Folded, it joins the town remainder, not the village of Red Hook.

A possible general rule from these: fold a NY CDP when its name is "not a USPS name" or "avoid" in the city-state file.

## Surprising or worth knowing

- **Dissolved villages** now appearing as CDPs: Barneveld (dissolved 31 Dec 2017), Cherry Creek (voted Feb 2017), Limestone (end of 2010), Mastic Beach (a village only 2010 to 2017).
- **Brighton CDP is the entire Town of Brighton**, and its mail is addressed Rochester (Brighton is only "acceptable" for two of four ZIPs), so many Brighton addresses will be written as Rochester.
- **Livonia Center** (currently folded, verdict fold, low confidence) is the closest call: a distinct hamlet 1.5 miles east of Livonia village with, per Wikipedia, its own post office (ZIP 14488), treated differently from the sibling hamlets Hemlock and Lakeville only because its name contains "Livonia". The input row's same_name_as_main_town is FALSE yet it is folded.
- **South Cairo**: the population-plurality town is Catskill (53%), but the name and the Town of Cairo's hamlet list tie it to Cairo. Keeping it as its own cell avoids the mismatch; if it were ever folded, the plurality rule would send it to the "wrong" town.
- **Aquebogue**: the input shows residents' ZIP as 11901 Riverhead, while Wikipedia gives 11931 for Aquebogue (probably a PO-box post office), so street mail may read Riverhead even though the hamlet name is a USPS primary name.
- **Mineville**: the Town of Moriah's hall is in Port Henry and "Moriah" is itself a separate hamlet and post office, so the town name would mislead.
- Straddlers Niverville (Kinderhook), Salisbury Mills (Cornwall) and Wells Bridge (Unadilla): the plurality town matches the local association.

## What could not be checked

- **Web search was unavailable**: the session's shared search budget was exhausted before my first query. All local-usage evidence comes from Wikipedia articles fetched directly (place and parent-town pages) plus the precomputed USPS mirror columns. No news datelines, real-estate listings, town websites, map labels or fire/library district pages were checked for any row; the CSV says "not found" for those signals.
- **No live USPS confirmations**: the USPS lookup page is a dynamic form and returned no results through WebFetch. The 14488 (Livonia Center) and 11931 (Aquebogue) post offices are from Wikipedia only.
- The Wikipedia page for the Cherry Creek CDP was a 404 at the URL tried; evidence is from the town article.
- Town hall location for Blenheim was not found.
- Verdicts most worth a second look with real search: Balmville, Duane Lake, Upper Red Hook, Livonia Center, North Blenheim.
