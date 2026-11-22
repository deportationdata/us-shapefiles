# New Hampshire CDPs: fold or own cell (25 sampled)

## Pattern

New Hampshire CDPs fall into two groups. Nineteen of the 25 carry their town's name and are, in Wikipedia's words each time, "the main village in the town of X": the Census outline of the built-up centre. They share the town's USPS primary name and have no separate identity, so folding is right for all of them (19 fold, all agreeing with the current rule). The six differently named CDPs are mixed: three are real villages whose name is the USPS primary name for their ZIP (Contoocook, Groveton, Union) and should stay their own cells; three are not localities anyone would name in an address (Mountain Lakes, Suissevale, Tilton Northfield) and should be folded. So the "same name as town" rule gets 22 of 25 right; the misses are all non-postal names. A rule of "own cell only if the CDP name is a USPS primary name" would get all 25 in this sample.

Counts: fold 22, own cell 3, relabel only 0, unclear 0. Disagreements with current treatment: 3.

## Disagreements with current treatment

- **Suissevale CDP** (Moultonborough; currently own cell, verdict fold, high confidence). A private subdivision run by a property owners association whose own address is "Moultonborough, NH 03254". Not a USPS name.
- **Mountain Lakes CDP** (Haverhill 77% / Bath 23%; currently own cell, verdict fold, medium). A recreational lake community; the Haverhill part is a village district (commissioners, water system), which is a special-purpose district rather than a municipality. Not a USPS name: addresses read Woodsville (03785) or Bath (03740). Folding whole into Haverhill mislabels the Bath 23%.
- **Tilton Northfield CDP** (Tilton 55% / Northfield 45%; currently own cell, verdict fold, medium). A Census compound for two town centres on opposite banks of the Winnipesaukee River, in two towns and two counties (Belknap, Merrimack). Nobody writes it as a city. The right outcome is to split it between Tilton and Northfield; folding the whole thing into plurality Tilton would put Northfield's centre in the wrong town and county. This is the one case where the fold mechanics (plurality town) matter more than the fold/own-cell choice.

## Surprising or worth noting

- **Groveton** is half of Northumberland's population and its everyday name (USPS primary, high school, the former mill), yet the town's own website gives its address as "Northumberland NH 03582" and never says Groveton. Kept as own cell, but it could equally be handled as an alias of the whole town; as an own cell, the "Northumberland" remainder is the half nobody names.
- **Union**: in the USPS mirror, Wakefield is flagged "avoid" as a city name, so Wakefield town residents are addressed as Union, Sanbornville, East Wakefield, etc. The town name is weaker than its village names here.
- **Bartlett**, **Plainfield**, **Goffstown**: the same-name CDP is only one of several villages (Glen/Intervale; Meriden; Pinardville). Folding the same-name CDP is still right; the other villages are not in this sample.
- **Wolfeboro CDP** also takes in the smaller village of Wolfeboro Falls. **New London** and **Plymouth** CDPs include college campuses (Colby-Sawyer, Plymouth State).
- No mergers, dissolutions or vanished places found.

## What I could not check

- **Web search was unavailable**: the shared search budget for this run was already used up, so every search query failed. All evidence comes from pages fetched directly by URL: the Wikipedia article for each of the 25 CDPs, the town articles for Hopkinton, Northumberland, Wakefield, Tilton, Northfield, Haverhill and Bartlett, and the official sites of Northumberland, Mountain Lakes District and Suissevale. For the 19 same-name CDPs the only web evidence is the Wikipedia article (one lookup each); no town websites, news datelines, listings or map labels were checked.
- **USPS live tool**: the lookup page returns only an empty form to a fetch, so no ZIP was confirmed live. All postal evidence is from the precomputed `zips` column.
- Town websites for Hopkinton and Wakefield returned 403; a Tilton-Northfield fire district site could not be located, so the joint fire district is unverified.
- Local usage (whether residents say "Contoocook" vs "Hopkinton", "Groveton" vs "Northumberland") is inferred from postal names and Wikipedia, not from news or listings.
