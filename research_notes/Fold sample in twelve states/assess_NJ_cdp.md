# New Jersey CDPs: fold or own cell (25 sampled)

## Pattern

All 25 are currently their own cells. On the evidence, 9 should stay own cells, 15 should fold, 1 is unclear. The split follows the post office closely: CDPs that are old villages with their own post office or ZIP and a primary USPS name (Dennisville, Leesburg, Williamstown, Newtonville, Cologne, Liberty Corner, Thorofare, Oak Ridge, Basking Ridge) are real localities, several of them the seat of a township whose own name is not a postal name. CDPs whose name USPS lists as 'avoid' or does not list at all are neighbourhoods, subdivisions, lake or beach association colonies, tiny hamlets, or Census constructs, and residents write another name. A recurring wrinkle: for many folds the name residents actually write is neither the CDP nor the township but a neighbouring post office (Absecon, Lavallette, Phillipsburg, Blairstown, Columbia, Browns Mills, Somerset, Bridgeton, Hewitt, Keyport).

## Disagreements with current treatment (all are own cell now, fold recommended)

- **Absecon Highlands CDP** (Galloway township, pop 1414, confidence medium): A 2020 statistical grouping of several subdivisions whose own name is not a usable postal name; residents write Absecon or Galloway. Nothing found that treats it as a locality distinct from Galloway.
- **Dover Beaches North CDP** (Toms River township, pop 1277, confidence high): A purely statistical name that no resident, post office or map uses; people say Ocean Beach, Chadwick Beach, Normandy Beach or Lavallette. No string will match it, so it should not be a cell; fold into Toms River.
- **East Freehold CDP** (Freehold township, pop 4987, confidence medium): USPS tells people not to use the name, mail is Freehold, and the only description found is as a neighbourhood. Anyone here would say Freehold.
- **Echelon CDP** (Voorhees township, pop 11896, confidence medium): The name comes from a mall that has since been renamed Voorhees Town Center, USPS says avoid it, and the township government sits in it. It is the centre of Voorhees, not a separate place.
- **Golden Triangle CDP** (Cherry Hill township, pop 4769, confidence high): One of eight census slices of Cherry Hill with a name that is not postal and means other things elsewhere. Everyone here says Cherry Hill.
- **Great Notch CDP** (Little Falls township, pop 3289, confidence medium): A genuine neighbourhood name (fire company, former station) but USPS says avoid it and it is a section of a small, compact township. Reporting Little Falls loses little.
- **Hainesburg CDP** (Knowlton township, pop 422, confidence medium): A 422-person hamlet with no postal name; mail says Columbia. Straddling: every source places it in Knowlton, while the sample shows residents split 50/50 with Blairstown township, so the plurality rule is a coin toss here and should be forced to Knowlton.
- **Hutchinson CDP** (Harmony township, pop 103, confidence medium): Tiny hamlet with no post office and no evidence of use as an address; residents write Phillipsburg. Not worth a cell of its own.
- **Marksboro CDP** (Frelinghuysen township, pop 186, confidence medium): Historic crossroads name with no postal standing today; residents write Blairstown. Too small and too little used to be reported instead of the township.
- **Presidential Lakes Estates CDP** (Pemberton township, pop 2353, confidence medium): A subdivision name with no postal standing; residents write Browns Mills. Should not be a locality cell. Note the name people would actually use is Browns Mills, not Pemberton.
- **Upper Greenwood Lake CDP** (West Milford township, pop 3687, confidence low): Mail is Hewitt and USPS says avoid the lake name; the township does not count it among its primary communities. Low confidence because lake communities often have strong identity and that could not be checked. Straddling: 98% West Milford, no issue.
- **Upper Pohatcong CDP** (Pohatcong township, pop 1714, confidence medium): No evidence anyone uses the name; it reads as a made-up label for the township's suburban end, and mail says Phillipsburg.
- **West Park CDP** (Hopewell township, pop 1506, confidence medium): Generic subdivision-style name with no postal standing; residents write Bridgeton. Not a locality people would name.
- **Weston CDP** (Franklin township, pop 2023, confidence medium): Historic name with no postal standing; residents write Somerset. Nothing found treating it as a present-day locality.
- **White Meadow Lake CDP** (Rockaway township, pop 8710, confidence medium): A large association community with real identity, but it is a subdivision in governmental and postal terms and its residents' city line is Rockaway. Fold, with the caveat that at 8,710 people it is a third of the township.

Unclear: **Cliffwood Beach CDP** (Aberdeen township): Conflict: a long-established, historically distinct bayshore section with a name people know, but USPS says not to use it (mail is Keyport) and it is governed entirely as part of Aberdeen. Could not run the news/listing searches that would settle whether people say Cliffwood Beach or Aberdeen.

## Surprising

- Hainesburg: the sample splits residents 50/50 between Knowlton and Blairstown townships, but every source places the hamlet in Knowlton. A plurality rule is a coin toss here.
- Basking Ridge: the name covers about 95% of Bernards Township by postal address (1995 New York Times, via Wikipedia), far beyond the 7,196-person CDP. Own cell keeps the name but puts most 'Basking Ridge' residents in the Bernards remainder.
- Dover Beaches North is a Census-only name built on the township's former name (Dover); the real names are Ocean Beach, Chadwick Beach, Normandy Beach and others, and mail is Lavallette.
- Echelon is named for a mall that has been renamed Voorhees Town Center and now houses the Voorhees township hall.
- Cologne, Dennisville and Liberty Corner have their own post office ZIPs (08213, 08214, 07938) that do not appear in the sample's residential `zips` column, which shows only the surrounding delivery ZIP.
- Thorofare: the township's own website writes 'West Deptford, NJ 08086' on the ZIP whose USPS primary name is Thorofare.
- Oak Ridge: Wikipedia says residents on the Jefferson side call the area Milton, while mail says Oak Ridge.

## Not checked

- The shared web-search budget ran out before any search could run. All evidence comes from direct reads of each place's Wikipedia article, the parent township's Wikipedia article for most, and six township websites. No news datelines, real-estate listings, map labels or fire/school district searches were done, so 'what people call it' is thin for every row and 'not found' appears often. Confidence is set accordingly.
- No USPS name was confirmed live: the USPS lookup page returns only an empty form to a plain fetch. All postal evidence is from the precomputed `zips` column plus ZIPs stated on Wikipedia and township sites.
- Weakest rows, worth a second look with search available: Cliffwood Beach, Upper Greenwood Lake, White Meadow Lake, Great Notch, Thorofare, Presidential Lakes Estates (subdivision status inferred from the name), Upper Pohatcong and West Park (construct status inferred from absence of any description).
