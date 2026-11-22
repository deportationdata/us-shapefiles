# Minnesota incorporated places: fold sample assessment (25 rows)

**Pattern.** All 25 are `own cell`, all agree with the current treatment. Every sampled city is classfp C5 and its own county subdivision: **no dependent (C1) city turned up in this sample.** Forest Lake and Inver Grove Heights absorbed their townships (2001 and 1965), so no same-name township remains there. The issues are tiny cities, cities with another city's postal name, and a few same-name townships.

**Disagreements with current treatment.** None.

## Flags

- **County-line straddler (1).** Clearwater city: 1,918 residents in Wright County and 4 in Stearns County.
- **Same-named city and township** (2020 populations; the township is a separate cell):

| City | City pop. | Same-named township | Township pop. | Bare name most likely means |
|---|---|---|---|---|
| Alexandria | 14,363 | Alexandria Township | 2,964 | city |
| Clearwater | 1,922 | Clearwater Township, Wright | 1,372 | city |
| Westbrook | 706 | Westbrook Township | 250 | city |
| Sacred Heart | 510 | Sacred Heart Township | 243 | city |
| Remer | 391 | Remer Township | 193 | city |
| Turtle River | 88 | Turtle River Township | 1,226 | township (14x bigger) |
| Wilton | 263 | Wilton Township, Waseca County (unrelated) | 381 | city, if near Bemidji |
| McKinley | 103 | McKinley Township, Cass (unrelated); McKinley UT, Kittson | 140; 38 | unclear |

- **Postal name belongs to another municipality.**
  - Birchwood Village (853): not a USPS name at all; mail goes as Saint Paul / White Bear Lake, and "Birchwood" is a name to avoid.
  - Lino Lakes (21,399): Circle Pines (75%) and Hugo (22%).
  - Medicine Lake (337): Minneapolis; the city is an enclave surrounded by Plymouth.
  - Lakeland Shores (339): Lakeland. McKinley: Gilbert (its post office closed in 1991). Regal: Belgrade, in another county. Turtle River and Wilton: Bemidji.
- **Postal name reaches beyond the city**: Osseo 55369 lists Maple Grove as an acceptable name, so the 2,688-resident city's name covers a much larger area; Forest Lake (Columbus), Alexandria (Forada), Glenville (London, Myrtle).
- **Tiny cities**: Regal (43), Henriette (57), Turtle River (88), Revere (89), Sunburg (94), McKinley (103), Marietta (116), Dent (173). All listed as active; confidence is medium for Regal, Henriette, McKinley and Turtle River because their governments' activity was not confirmed.
- Wikipedia's Medicine Lake article currently gives an implausible "estimated 1,342 in 2025"; the 2020 count is 337.

## What I could not check

- The web search budget for this run was exhausted (shared with other agents) before any search went through, so the per-place lookup is the Wikipedia article (fetched for all 25 places, full article for the flagged ones) plus the repository's own county-subdivision and 2020 block-population files. No municipal websites, news datelines or map labels were opened.
- USPS evidence is from the precomputed `zips` column only. The live USPS tool is a form that WebFetch could not submit, so nothing was confirmed live.
- Whether the smallest governments are actually meeting was not independently confirmed; Census lists all 25 as active (funcstat A).
