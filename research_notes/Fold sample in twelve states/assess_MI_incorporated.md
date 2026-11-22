# Michigan incorporated places: fold or own cell (25 sampled)

## Pattern

The sample is 15 cities (classfp C5) and 10 villages (C1). Every city is independent of any township and is its own county subdivision, so all 15 are `relabel only`: there is no township to fold into. The 10 villages are real governments inside a township, each with a council and usually a utility (water, sometimes sewer, trash); a minority run their own police (Almont, Schoolcraft) or fire department (Eastlake, Garden), and the township typically supplies fire, assessing, tax billing and elections. Six of the ten villages have a name different from their township (Ahmeek, Barton Hills, Eastlake, Freeport, Rosebush, South Range), and for five of those the village name is the USPS primary name while the township name is either not a postal name or belongs to a different community, so `own cell` is clearly right. The four same-name villages (Almont, Caledonia, Garden, Schoolcraft) are the only place where the choice is a matter of judgement, and there it barely matters for labelling: village and township share the name and the ZIP name, so a free-text "Almont, MI" cannot tell them apart whichever way the cell is drawn.

Verdicts: 15 relabel only, 9 own cell, 1 unclear, 0 fold.

## Disagreements with current treatment

None outright. One row is `unclear`:

- **Caledonia village** (Kent County, 1,622): a real government with council, planning commission and water/sewer, but no village police found (links point to the Kent County Sheriff), the township runs fire, bills the village's taxes and gives its name to the library branch, and "Caledonia" in postal and everyday use means the whole township area. It is the closest thing to a fold in the sample. The label is "Caledonia" either way.

## Weak own-cell cases

- **Barton Hills village** (316): USPS says to avoid the name; every address, including the village office, is "Ann Arbor, MI 48105". Police is the county sheriff and fire is Ann Arbor Township. Kept as own cell (low confidence) only because folding would relabel it "Ann Arbor charter township", which USPS also says to avoid, and any free-text string will say "Ann Arbor" and land on the city regardless.
- **Almont, Garden, Schoolcraft**: same-name villages kept as own cell at medium confidence on the strength of their governments (own police in Almont and Schoolcraft; water and volunteer fire in Garden).

## Surprising or worth knowing

- **Lathrup Village city**: a city despite its name, entirely surrounded by Southfield, and its ZIP 48076 has Southfield as the USPS primary name with Lathrup Village only acceptable. Addresses there will often read "Southfield".
- **Douglas city**: officially "City of the Village of Douglas"; it was a village in Saugatuck Township until a December 2004 vote made it a city. A quarter of its residents are in the Fennville ZIP.
- **Mackinac Island city**: formed in 1899 from the former Holmes Township and Village of Mackinac; no township exists.
- **Schoolcraft Township Hall** has a Vicksburg address, so the township is not simply the village's hinterland.
- **Leslie city**: Wikipedia gives a 2020 population of 2,167 against 1,927 in the sample CSV; not resolved.
- **Plymouth city** and Plymouth Township share the postal name; same ambiguity as the same-name villages, but between two independent units.

## What could not be checked

- **Live USPS tool**: one attempt returned only the empty form, so nothing was confirmed live. All postal evidence is from the precomputed `zips` column.
- **Web search budget ran out** partway through (shared limit across agents). All ten villages got a Wikipedia read plus one search; the follow-up searches for Eastlake and Rosebush local news usage, Lathrup Village police, and any Douglas/Saugatuck consolidation news did not run. The Lathrup Village city website did not load.
- Police arrangements were not found for Ahmeek, Eastlake, Freeport, Garden, Rosebush and South Range; fire arrangements were not found for Freeport, Rosebush and South Range.
- Township populations for the same-name townships (Almont, Caledonia, Garden, Schoolcraft) were not looked up.
- No maps (Google/OSM labels), real-estate listings or news datelines were checked for any row. Items taken from search-result summaries are marked "(snippet)" in the CSV.
