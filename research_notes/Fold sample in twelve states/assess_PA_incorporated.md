# Pennsylvania incorporated places: fold sample assessment (25 rows)

**Pattern.** All 25 are `relabel only`, all agree with the current treatment. Every sampled borough and city (Aliquippa and Arnold are cities) is classfp C5 and is its own county subdivision with identical population; none straddles a county line and none has merged or dissolved. The real issues in Pennsylvania are name ambiguity and postal names, not the fold.

**Disagreements with current treatment.** None.

## Flags

- **Same-named borough/township pairs** (2020 populations from the repository's block file):
  - **Hatfield**: borough 3,496, surrounded by Hatfield Township 18,640 (Montgomery County). Both use Hatfield 19440. A bare "Hatfield, PA" is more likely the township (about 84% of the combined population).
  - **Somerset**: borough 6,048 (county seat), surrounded by Somerset Township 12,083; a second Somerset Township in Washington County has 2,581. A reader most likely means the borough, but the township is twice its size and shares ZIP 15501.
  - **Darby**: borough 10,715 and Darby Township 9,219 (Delaware County), plus the much larger Upper Darby Township. "Darby, PA" most likely means the borough, whose ZIP 19023 has Darby as its primary name.
  - **Exeter**: borough 5,514 (Luzerne County); Exeter Township next to it 2,051; Exeter Township in Wyoming County 625; Exeter Township in Berks County 25,466. Postally "Exeter" points to the Luzerne borough (acceptable name under Pittston 18643), but by population a reader could easily mean the Berks township. Confidence medium on which is meant.
- **Postal name belongs to another municipality.**
  - Pittsburgh: Bellevue (8,311), Millvale (3,376), Wilkinsburg (14,349).
  - New Kensington: Arnold city. Clarks Summit: Clarks Green. Pittston: Exeter. Collegeville: Trappe. York: West York.
  - Freeland: Jeddo, which is not a USPS city name at all.
  - Partial: Hydetown (65% Titusville), Tatamy (13% Easton).
- **Postal name reaches beyond the borough**: Moscow 18444 is the postal name for five surrounding townships; Carnegie (Heidelberg, Collier Township); Linesville (Espyville); Darby (Collingdale).
- **Proposed annexation, not done: Wilkinsburg.** A drive from 2020 to merge it into Pittsburgh reached the Pennsylvania Supreme Court, which held the 1903 annexation law defunct; it remains a separate borough.
- **Tiny boroughs**: Jeddo (108, least populous borough in Luzerne County), Mount Gretna (193), Orrstown (214), Spartansburg (281), Grampian (361), Seward (411). All listed as active.
- **Name wider than the borough: Mount Gretna.** The borough has 193 residents, but "Mount Gretna" in ordinary use covers about 1,500 year-round residents in neighbourhoods lying in West Cornwall and South Londonderry townships.

## What I could not check

- The web search budget for this run was exhausted (shared with other agents) before any search went through, so the per-place lookup is the Wikipedia article (fetched for all 25 places, full article for the flagged ones) plus the repository's own county-subdivision and 2020 block-population files. No municipal websites, news datelines or map labels were opened.
- USPS evidence is from the precomputed `zips` column only. The live USPS tool is a form that WebFetch could not submit, so nothing was confirmed live.
- Whether the smallest governments are actually meeting was not independently confirmed; Census lists all 25 as active (funcstat A).
