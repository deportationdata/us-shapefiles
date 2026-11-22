# Wisconsin incorporated places: fold sample assessment (25 rows)

**Pattern.** All 25 are `own cell`, all agree with the current treatment. Every sampled city and village is classfp C5 and its own county subdivision; Wisconsin cities and villages are independent of the towns around them, which Wikipedia states outright for Waupaca and Webster. The recurring issue is that 15 of the 25 share their name with a separate town, usually the one surrounding or adjoining them.

**Disagreements with current treatment.** None.

## Flags

- **County-line straddlers (2).**
  - Brooklyn village: 1,026 residents in Dane County, 498 in Green County.
  - Turtle Lake village: 959 in Barron County, 78 in Polk County.
- **Same-named city/village and town** (2020 populations; the town is a separate cell):

| Place | Place pop. | Same-named town | Town pop. | Bare name most likely means |
|---|---|---|---|---|
| Fond du Lac city | 44,678 | Fond du Lac town | 3,681 | city |
| Sparta city | 10,025 | Sparta town | 3,253 | city |
| Sheboygan Falls city | 8,211 | Sheboygan Falls town | 1,823 | city |
| Waupaca city | 6,282 | Waupaca town | 1,194 | city |
| Saukville village | 4,258 | Saukville town | 1,765 | village |
| Trempealeau village | 1,843 | Trempealeau town | 1,951 | ambiguous, village is the centre |
| Sharon village | 1,586 | Sharon town, Walworth (also Sharon town, Portage, 2,123) | 861 | village |
| Brooklyn village | 1,524 | Brooklyn town, Green (also Green Lake 1,787, Washburn 311) | 1,108 | village |
| Hillsboro city | 1,397 | Hillsboro town | 787 | city |
| Princeton city | 1,267 | Princeton town | 1,519 | ambiguous, city is the centre |
| Turtle Lake village | 1,037 | Turtle Lake town, Barron | 640 | village |
| Webster village | 694 | Webster town, Vernon County (unrelated) | 821 | village (by ZIP 54893) |
| Prentice village | 563 | Prentice town | 440 | village |
| Neshkoro village | 412 | Neshkoro town | 565 | ambiguous |
| Elderon village | 161 | Elderon town | 644 | ambiguous, town is 4x bigger |

- **Postal name belongs to another municipality.**
  - Buffalo City (1,007): mail goes as Cochrane 54622, the adjoining village.
  - Elderon: delivery ZIPs are Eland (62%) and Wittenberg (38%).
  - Partial: Kellnersville (35% Whitelaw), Coleman (8% Pound), Saukville (7% Grafton).
- **Tiny villages**: Steuben (122), Elderon (161), Ferryville (191), Kellnersville (307). All listed as active.
- Webster village lies inside the Town of Meenon, not a Town of Webster; the same-named town is in Vernon County.

## What I could not check

- The web search budget for this run was exhausted (shared with other agents) before any search went through, so the per-place lookup is the Wikipedia article (fetched for all 25 places, full article for the flagged ones) plus the repository's own county-subdivision and 2020 block-population files. No municipal websites, news datelines or map labels were opened.
- USPS evidence is from the precomputed `zips` column only. The live USPS tool is a form that WebFetch could not submit, so nothing was confirmed live.
- Whether the smallest governments are actually meeting was not independently confirmed; Census lists all 25 as active (funcstat A).
