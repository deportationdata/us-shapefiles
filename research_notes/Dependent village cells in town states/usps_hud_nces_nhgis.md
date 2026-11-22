# USPS city names, HUD, NCES and IPUMS NHGIS: how they treat VT villages and CT boroughs versus NY and MI villages (checked 17 Nov 2026)

Method notes for the report writer:
- "Direct" = I ran the lookup, downloaded the file or read the raw page text myself and tabulated it. Counts are my own tabulations.
- "Via summariser" = page read through a summarising fetch tool; short quotes are exact, longer passages are paraphrased.
- "Snippet" = from a web search result only; the page was not opened.
- Answer codes used below: (a) treats villages/boroughs the same in all four states; (b) draws the project's line (town-only in VT/CT, villages recognised in NY/MI); (c) no rule.
- Village-to-town links come from Census PEP Vintage 2025 (sub-est2025.csv, SUMLEV 071). That file has 29 Vermont villages (there is no Jericho village record, only Jericho town), 10 Connecticut boroughs including consolidated Naugatuck, 532 New York villages and 253 Michigan villages. The project crosswalk still carries a Jericho village row.
- Scratch files: `/private/tmp/claude-501/-Users-graeme--claude-spares-spare-nsjsKl/8d76e247-022c-4fc8-b950-c1098d762aeb/scratchpad/usps/` (per-village table in `village_usps_status.csv`, scripts `quant.py`, `q.py`, `name.py`, `lm2.R`, `uglg.py`).

## 1. USPS: is the postal city name the village/borough or the town?

### Takeaway
(c) No rule, and in practice the opposite of the project's line in Vermont: where a Vermont village has a different name from its town, the USPS recommended city name is almost always the village (12 of 14), and the town name is sometimes a "name to avoid" (Rockingham, Burke, Enosburg). Connecticut is mixed (3 of 6 boroughs are the recommended name, with the town as an accepted alternative). New York (74 percent) and Michigan (92 percent) villages are also mostly the recommended name, so address-derived city strings will say "Bellows Falls" and "Danielson" just as they say "Lake Placid" and "Lake Orion".

### Cited Findings
- (Direct, live lookup in the USPS tool, 14 ZIP codes) The tool returns three lists per ZIP: "RECOMMENDED CITY NAME", "OTHER CITY NAMES RECOGNIZED FOR ADDRESSES IN THIS ZIP CODE" and "CITY NAMES TO AVOID", with the instruction "For more rapid delivery, please use the recommended or recognized city names whenever possible for this ZIP Code." — [USPS Cities by ZIP Code](https://tools.usps.com/zip-code-lookup.htm?citybyzipcode)
- (Direct, live USPS) Vermont results, as recommended / recognised / avoid:
  - 05101: BELLOWS FALLS / none / Gageville, North Westminster, **Rockingham**.
  - 05154: SAXTONS RIVER / none / none.
  - 05661: MORRISVILLE / Elmore, **Morristown** / Cadys Falls, Cleveland Corner, Garfield, Lake Lamoille, Morrisvl, Morrisvle, Mud City.
  - 05450: ENOSBURG FALLS / Enosburg Fls / 14 names including **Enosburg**, East Enosburg, West Enosburg, Enosburg Center.
  - 05830: DERBY LINE / none / Holland. 05829: DERBY / none / none.
  - 05860: ORLEANS / Brownington / Evansville, Westmore.
  - 05859: NORTH TROY / Jay, Jay Peak / none.
  - 05257: NORTH BENNINGTON / N Bennington / five names.
  - 05464: JEFFERSONVILLE / Jeffersonvlle / Madonna. 05342: JACKSONVILLE / none / none.
  — [USPS Cities by ZIP Code](https://tools.usps.com/zip-code-lookup.htm?citybyzipcode)
- (Direct, live USPS) Connecticut: 06239: DANIELSON / **Killingly** / East Brooklyn, South Killingly. 06351: JEWETT CITY / **Griswold**, Lisbon / Hopeville, Preston. — [USPS Cities by ZIP Code](https://tools.usps.com/zip-code-lookup.htm?citybyzipcode)
- (Direct, live USPS) Comparison: 12946: LAKE PLACID NY / none / none (town is North Elba, which is not a USPS name at all). 48362: LAKE ORION MI / Orion / **Orion Township, Orion Twp** to avoid. — [USPS Cities by ZIP Code](https://tools.usps.com/zip-code-lookup.htm?citybyzipcode)
- (Direct) After about ten scripted lookups the USPS tool stopped answering, so the rest comes from an open mirror: the `zipcodes` project's `zips.json.bz2`, last updated 1 Nov 2026, which its README says is built from unitedstateszipcodes.org and the USPS ZIP Locale Detail file. Its primary / acceptable / unacceptable names matched the live USPS result exactly for all 14 ZIP codes I checked both ways. — [seanpianka/zipcodes](https://github.com/seanpianka/zipcodes)
- (Direct, mirror) More Vermont: 05081 Wells River (no alternates); 05871 West Burke, with **Burke** to avoid; 05051 Newbury; 05822 Barton; 05868 Troy; 05361 Whitingham; 05444 Cambridge; 05201 Bennington, with **Old Bennington** to avoid; 05091 Woodstock; 05488 Swanton. There is no ZIP whose primary name is Rockingham, Morristown, Enosburgh or Burke. Derby Center is not a USPS name in any list. — [seanpianka/zipcodes](https://github.com/seanpianka/zipcodes)
- (Direct, mirror) More Connecticut: 06750 Bantam and 06759 Litchfield are separate ZIPs, neither listing the other. 06475 Old Saybrook, with **Fenwick** to avoid. 06340 Groton, with **Groton Long Point** and "Borough" to avoid. 06460 Milford, with Woodmont in no list. 06378 Stonington; 06470 Newtown. Killingly is an accepted name in five ZIPs (Danielson, Dayville, East Killingly, and PO-box ZIPs Ballouville and Rogers) and the primary name in none. — [seanpianka/zipcodes](https://github.com/seanpianka/zipcodes)
- (Direct, mirror) More New York: 10583 Scarsdale (Heathcote accepted; Edgemont to avoid). 10591 **Tarrytown**, with Sleepy Hollow and North Tarrytown accepted, so Sleepy Hollow village mail defaults to the neighbouring village's name; "Mount Pleasant" is not a USPS name. 10573 Port Chester (Rye Brook accepted). 14217 and 14223 **Buffalo**, with Kenmore, Tonawanda and "Town Of Tonawanda" accepted. 10562 Ossining. — [seanpianka/zipcodes](https://github.com/seanpianka/zipcodes)
- (Direct, mirror) More Michigan: 48359, 48360 and 48362 are all Lake Orion (Orion accepted, Orion Township to avoid). 48442 Holly. 48380 and 48381 Milford, with **Milford Twp** to avoid. 48025 **Franklin**, with Beverly Hills and Bingham Farms accepted and **Southfield Township** to avoid, so Michigan's largest village (Beverly Hills, 10,449) is not its own default postal name. — [seanpianka/zipcodes](https://github.com/seanpianka/zipcodes)
- (Direct, my tabulation of the mirror against PEP village-town pairs; a name counts if it appears anywhere in the state in that role) Villages/boroughs whose name differs from their town's name, by best USPS status of the village name:

  | State | Differently named | Primary | Accepted | To avoid | Not a USPS name |
  |---|---|---|---|---|---|
  | VT | 14 | 12 (86%) | 0 | 1 (Old Bennington) | 1 (Derby Center) |
  | CT | 6 | 3 (Bantam, Danielson, Jewett City) | 0 | 2 (Fenwick, Groton Long Point) | 1 (Woodmont) |
  | NY | 335 | 249 (74%) | 33 | 42 | 11 |
  | MI | 155 | 143 (92%) | 9 | 2 | 1 |

  Same-named villages are primary almost without exception (VT 15 of 15, CT 4 of 4, NY 193 of 197, MI 97 of 98). — [seanpianka/zipcodes](https://github.com/seanpianka/zipcodes); [Census PEP sub-est2025.csv](https://www2.census.gov/programs-surveys/popest/datasets/2020-2025/cities/totals/sub-est2025.csv)
- (Direct, same tabulation) Status of the enclosing town's name for those differently named villages: VT 9 primary, 1 accepted (Morristown), 3 to avoid (Rockingham twice, Burke), 1 absent (Enosburgh; the spelling "Enosburg" is to avoid). CT 4 primary, 2 accepted (Killingly, Griswold). NY 149 primary, 10 accepted, 62 to avoid, 114 absent. MI 44 primary, 7 accepted, 4 to avoid, 100 absent. — same sources.
- (Direct, same tabulation) New York villages that are not their own postal name are mostly small suburban ones: to avoid, e.g. Asharoken, Belle Terre, Brookville, Cove Neck; absent, e.g. Cayuga Heights, Flower Hill, Munsey Park; accepted only, e.g. Airmont, Blasdell, East Williston. Michigan: Barton Hills and Lakewood Club to avoid; Estral Beach absent. — same sources.
- (Via summariser) Census Bureau on the general point: the postal city name "may differ from the legal municipality or district in which the housing unit is actually located", and ZIP Codes "do not follow legal city boundaries and frequently extend beyond the actual city limits". — [Census: USPS city versus census geography](https://www.census.gov/programs-surveys/geography/guidance/geo-areas/usps_census_city.html)

### Inferences
- USPS naming follows post offices, not municipal law. Vermont villages were the post-office settlements, so the village name is the postal name and the town name is often not even accepted. This is the reverse of "town is the unit in Vermont".
- For ICE address strings: a record reading "Bellows Falls, VT", "Morrisville, VT", "Enosburg Falls, VT", "Danielson, CT" or "Jewett City, CT" is the normal postal form, not an error, and the town names Rockingham, Morristown, Enosburgh, Killingly and Griswold will rarely appear. Under the project's fold, the name lookup must map these village/borough names to the town cell. At least 12 Vermont and 3 Connecticut names need this.
- The postal name also covers more than the village. A ZIP named for a village serves the surrounding town and sometimes other towns (05661 Morrisville accepts Elmore; 05860 Orleans accepts Brownington; 05859 North Troy accepts Jay; 06351 Jewett City accepts Lisbon). So "city = village name" does not show the address is inside the village, in any of the four states: Lake Orion's three ZIPs cover Orion Township, whose own name is to avoid.
- That cuts in favour of folding where it is done (the postal string cannot separate village from town remainder), but it applies equally to New York and Michigan, where the project keeps villages. A string match on "Lake Orion" or "Lake Placid" will over-assign town-remainder addresses to the village cell unless coordinates are used.
- Connecticut is the only state where USPS partly agrees with the project: the town name is primary or accepted for every borough ZIP, and three small boroughs (Fenwick, Groton Long Point, Woodmont) are not usable postal names.

### Gaps
- The quantification uses name matching within a state, not ZIP geometry, so "town name is primary" can be satisfied by a post office elsewhere in the town (Derby for Derby Line, Barton for Orleans, Newbury for Wells River) or, rarely, by an unrelated same-named post office. I did not compute which name the ZIP covering each village centroid carries.
- Only 14 ZIP codes were verified live at USPS; the rest relies on the mirror, which agreed on all 14.
- Villages split across towns were assigned to the town holding most of their population.
- I found no source on what city string ICE actually records (postal, facility-entered or geocoded).

## 2. HUD: crosswalks, CDBG definitions, Low/Mod data, Fair Market Rent areas

### Takeaway
(a) for everything that lists governments: HUD's statute, its Unit of General Local Government layer and its Low/Mod "local government" file carry VT villages and CT boroughs as places alongside whole towns, exactly as for NY and MI villages. HUD's ZIP crosswalk and FMR areas use county subdivisions (towns) and have no village level in any state, so no HUD product is town-only in New England while recognising villages in NY/MI.

### Cited Findings
- (Direct, page text) HUD-USPS crosswalk types are: zip-tract, zip-county, zip-cbsa, zip-cbsadiv, zip-cd, their five reverses, and "zip-countysub (Available 2nd Quarter 2018 onwards)" and "countysub-zip (Available 2nd Quarter 2018 onwards)". There is no ZIP-to-place file. — [HUD USPS crosswalk API](https://www.huduser.gov/portal/dataset/uspszip-api.html)
- (Direct, page text) Field definition: "USPS_ZIP_PREF_CITY: USPS preferred city name. Note: ZIP code preferred names frequently do not align with administrative/political names. Furthermore, ZIP code boundaries frequently do not align with administrative/political boundaries." — [HUD-USPS ZIP Code Crosswalk Files, Documentation tab](https://www.huduser.gov/portal/datasets/usps_crosswalk.html)
- (Snippet) HUD has received the preferred name since 2021 Q1 and "only USPS preferred name is provided", not the names to avoid. — [Cityscape vol. 23 no. 3, ch. 11](https://www.huduser.gov/portal/periodicals/cityscpe/vol23num3/ch11.pdf)
- (Via summariser) Statute: a unit of general local government is "any city, county, town, township, parish, village, or other general purpose political subdivision of a State". A "city" is "any unit of general local government which is classified as a municipality by the United States Bureau of the Census", or a town or township that, among other tests, "contains within its boundaries no incorporated places as defined by the United States Bureau of the Census" that have not signed cooperation agreements with it. — [42 U.S.C. 5302](https://www.law.cornell.edu/uscode/text/42/5302)
- (Via summariser) The regulation repeats this: "Unit of general local government shall have the meaning provided in section 102(a)(1) of the Act", and the town/township branch of "City" requires that it "Contains within its boundaries no incorporated places as defined by the United States Bureau of the Census" lacking a cooperation agreement. Neither "village" nor "borough" appears in the regulation's own definitions. — [24 CFR 570.3](https://www.law.cornell.edu/cfr/text/24/570.3)
- (Direct, service metadata) HUD's UGLG layer: "a city, county, town, parish, village, or other general-purpose political subdivision of a State", built from "Summary Level 050 - State-County; Summary Level 060 - County Subdivision; Summary Level 070 - State-County-County Subdivision-Place/Remainder; Summary Level 160 - Place; Summary Level 170", excluding entitlement grantees, coverage 2020. — [HUD UGLG feature service](https://services.arcgis.com/VTyQ9soqVukalItT/ArcGIS/rest/services/Unit_of_General_Local_Government/FeatureServer/16)
- (Direct, query of that layer) Vermont, 287 units: 242 towns and 4 other county subdivisions (level 060), 32 villages and 9 cities (level 160). "Bellows Falls village" and "Rockingham town" are both units, as are "Woodstock village" and "Woodstock town". Connecticut, 178 units: 148 towns (060), 8 boroughs and 18 cities (160), including Bantam, Danielson, Jewett City, Litchfield and Stonington boroughs beside Killingly, Griswold, Litchfield and Stonington towns. New York and Michigan returns were cut at 1,000 rows each but show the same shape: 360 villages (160) and 579 towns (060) in the NY extract, with "Ossining village" and "Ossining town"; 125 villages and 705 townships in the MI extract. — [HUD UGLG feature service](https://services.arcgis.com/VTyQ9soqVukalItT/ArcGIS/rest/services/Unit_of_General_Local_Government/FeatureServer/16)
- (Direct, page text) Low/Mod local government file: "estimates of the number of low- and moderate-income individuals (LMISD) by Summary level 160: Places, Summary Level 170: Consolidated Cities, Summary Level 050: County, and Summary Level 060: County Subdivision geographies based on the 2016-2020 American Community Survey". — [HUD Exchange: LMISD by Local Governments](https://www.hudexchange.info/programs/acs-low-mod-summary-data/acs-low-mod-summary-data-local-government/)
- (Direct, workbook, one sheet, key column headed "PLACE/MCD") Rows by state: Vermont 33 villages, 9 cities and 138 CDPs as places, plus 242 towns as county subdivisions. Connecticut 10 boroughs, 20 cities, 185 CDPs, plus 169 towns. New York 534 villages, 62 cities, 697 CDPs, plus 933 towns. Michigan 253 villages, 280 cities, 212 CDPs, plus 1,122 townships and 118 charter townships. — [ACS 2016-2020 Low-Mod All Local Governments](https://files.hudexchange.info/resources/documents/ACS-2020-Low-Mod-Local-Gov-All.xlsx)
- (Direct, same workbook) Town rows are whole towns, village rows overlap them. Low/mod universe: Rockingham town 4,895 and Bellows Falls village 2,835; Woodstock town VT 2,875 and Woodstock village 1,055; Stonington town 18,235 and Stonington borough 900; Litchfield town 7,835, Litchfield borough 1,070, Bantam borough 605; Killingly town 16,880 and Danielson borough 3,940; Ossining town 34,900 and Ossining village 23,095; Orion charter township 39,105 and Lake Orion village 3,025; Holly township 11,480 and Holly village 6,075. — [ACS 2016-2020 Low-Mod All Local Governments](https://files.hudexchange.info/resources/documents/ACS-2020-Low-Mod-Local-Gov-All.xlsx)
- (Snippet) FMR areas: "In the six New England States (Connecticut, Maine, Massachusetts, New Hampshire, Rhode Island, and Vermont), the primary unit of geography is the town level for historical reasons, instead of the county. These towns are equivalent to 'county subdivisions' used by the Census Bureau." — [HUD FY26 FMR Methodology](https://www.huduser.gov/portal/datasets/fmr/fmr2026/FY26-Public-FMR-Methodology.pdf)

### Inferences
- HUD's legal definition puts VT villages and CT boroughs on the same footing as NY and MI villages: all are Census "municipal" governments (earlier notes, section 3), so all are "cities" for CDBG, and the town or township around them qualifies only if its incorporated places cooperate. The statute treats the dependent village as the thing that can block the town, in every state.
- The Low/Mod file gives a ready join for either design in all four states (village row, whole-town row) but no town-remainder row. A folded VT/CT town cell matches the 060 row directly; a NY/MI village cell matches the 160 row; a NY/MI town-remainder cell has no row and needs subtraction.
- FMR areas and the ZIP-countysub crosswalk are town-based in New England, which agrees with a town cell in VT and CT. But outside New England FMR areas are counties, and the crosswalk has county subdivisions (whole towns and townships) and no place file anywhere, so neither product recognises villages in NY or MI. They are (a), not (b).
- The crosswalk's preferred-city field will hand a HUD user "Bellows Falls" or "Danielson" as the city for a ZIP whose county subdivision is Rockingham or Killingly, so the two fields disagree for exactly the differently named villages in section 1.

### Gaps
- The crosswalk files themselves need a login, so I did not open a ZIP-COUNTYSUB file; the description rests on the documentation and API page.
- The FMR methodology PDF, FMR area files and the eCFR page blocked automated reading; the FMR quote is from a search snippet and the regulation from Cornell's copy.
- I did not check the CDBG entitlement list for whether any NY village is a metropolitan city in its own right.
- The UGLG counts for NY and MI are partial (1,000-row limit). Its 32 Vermont villages and the Low/Mod file's 33 exceed the 29 in PEP 2025 because they reflect 2020 boundaries (they include since-dissolved villages and Essex Junction).

## 3. NCES: school districts, locales, Common Core of Data

### Takeaway
NCES is not informative for this question. Its locale codes are built from Census urban areas and principal cities, not from places or towns, and I did not find NCES material that treats village or borough units differently by state.

### Cited Findings
- (Via summariser) NCES "classifies all territory in the U.S. into four types – City, Suburban, Town, and Rural", and the classifications "begin with standard urban and rural criteria defined by the Census Bureau". City locales are territory inside a principal city within an urban area of 50,000 or more; "Town" is territory in a smaller urban area, graded by distance. The page does not mention places, county subdivisions, minor civil divisions, New England or townships. — [NCES EDGE: Locale boundaries](https://nces.ed.gov/programs/edge/Geographic/LocaleBoundaries)

### Inferences
- An NCES "Town" locale is a settlement-size class, not a municipality, so it says nothing about whether a village or its town is the unit. A dependent village could only matter if it were an OMB principal city, and no VT village or CT dependent borough is large enough (largest: Bellows Falls 2,706; Danielson 4,265, from PEP 2025).
- The Common Core of Data "city" for a school or district is an address field, so it would carry the postal names in section 1 (village names in Vermont), not a legal unit.

### Gaps
- I did not open EDGE school district boundary files or the CCD directory, so I cannot say whether any district in VT or CT is coextensive with a village or borough (Vermont historically had incorporated school districts), nor compare with NY and MI, where districts generally do not follow village lines. No source was opened for this; treat it as unverified.
- The CCD address-field statement is my reading of what the field is, not a quoted NCES definition.

## 4. IPUMS NHGIS: place versus county subdivision guidance

### Takeaway
(a), by silence. NHGIS offers places and county subdivisions as parallel levels nationwide and, in the pages checked, gives no advice to prefer towns in New England and no special handling of dependent villages.

### Cited Findings
- (Via summariser) "Nominally integrated tables provide data for up to 8 geographic levels": nation, regions, divisions, states, counties, census tracts, county subdivisions and places. The stated use is "Studying changes in characteristics of places and county subdivisions according to their legal definitions." Standardized (2010-geography) tables cover ten levels, again including both county subdivisions and places. The page says nothing about New England, minor civil divisions or towns. — [NHGIS time series tables](https://www.nhgis.org/time-series-tables)
- (Via summariser) Place point files "depict the locations of incorporated, unincorporated, and census-designated places" from 1900 to 2015; the page does not mention minor civil divisions, New England towns, townships or villages and has no state-specific rules. — [NHGIS place points](https://www.nhgis.org/place-points)

### Inferences
- NHGIS passes through the Census structure: a VT village or CT borough is a place record, its town is a county subdivision record, the same as in NY and MI. A user wanting New England towns must know to pick county subdivisions; NHGIS does not steer them.
- Because place points are places only, a place-based NHGIS workflow would show Bellows Falls, Danielson and Jewett City but not Rockingham, Killingly or Griswold, which is the reverse of the project's fold.

### Gaps
- I did not find or open an NHGIS user note, FAQ or crosswalk document addressing New England towns or strong-MCD states; absence on two pages is not proof none exists.
- I did not check whether NHGIS extracts expose the place/remainder level (070) for these states.

## 5. Census QuickFacts and combined place/MCD listings

### Takeaway
(a). QuickFacts lists places and minor civil divisions of 5,000 or more side by side in all four states. No VT village or dependent CT borough appears, but only because none reaches 5,000.

### Cited Findings
- (Direct, page text) "QuickFacts provides statistics for all states and counties. Also for cities and towns with a population of 5,000 or more." "Geographies with populations below 5,000 are not currently shown in QuickFacts." Release notes refer to "Facts Updated for Places and Minor Civil Divisions". — [Census QuickFacts FAQ](https://www.census.gov/quickfacts/fact/faq/US/PST045225)
- (Direct, page titles returned) QuickFacts profiles exist for "Ossining town, Westchester County, New York" and "Ossining village, New York"; "Port Chester village, New York"; "Orion charter township, Oakland County, Michigan"; "Holly village, Michigan"; "Bennington town, Bennington County, Vermont"; "Killingly town, Northeastern Connecticut Planning Region, Connecticut". — [Census QuickFacts](https://www.census.gov/quickfacts/)
- (Direct, PEP 2025 tabulation) Villages or boroughs at 5,000 or more: Vermont 0 of 29 (largest Bellows Falls 2,706, Morrisville 2,404, Swanton 2,380); Connecticut 1 of 10, and that one is consolidated Naugatuck (next: Danielson 4,265, Jewett City 3,456); New York 112 of 532; Michigan 5 of 253 (Beverly Hills 10,449, New Haven 6,749, Milford 6,520, Dundee 6,008). — [Census PEP sub-est2025.csv](https://www2.census.gov/programs-surveys/popest/datasets/2020-2025/cities/totals/sub-est2025.csv)

### Inferences
- QuickFacts looks like the project's line (towns only in VT/CT, villages present in NY/MI) but the cause is the population threshold, the same effect the earlier notes found for Michigan in BLS LAUS. It also publishes NY towns and MI townships, overlapping their villages.
- Connecticut town profiles are now keyed to planning regions, not the old counties, which matters for any name-based join.

### Gaps
- I did not find a QuickFacts statement listing which states' minor civil divisions are included; the examples show NY, MI, VT and CT all are.
- ACS summary level 170 (consolidated city) was not examined; it is not relevant to dependent villages in these states.

## Overall: does this change the earlier bottom line?

### Takeaway
No. The earlier conclusion stands and is slightly strengthened: none of USPS, HUD, NCES, NHGIS or QuickFacts draws the project's line as a rule. HUD joins the federal sources that list VT villages and CT boroughs as governments just like NY and MI villages. USPS adds a new point against the asymmetry as a naming convention in Vermont: the everyday postal name there is the village, not the town.

### Cited Findings
- Summary of sections 1 to 5; every underlying fact is cited there. The earlier bottom line being tested is in [other_data_products.md](other_data_products.md): the asymmetry is "a recognised convention in reference and labelling sources ... but not in federal data that enumerates governments or pays them".

### Inferences
- Classification: USPS (c); HUD statute, UGLG layer and Low/Mod file (a), overlapping place plus whole town; HUD ZIP crosswalk and FMR areas (a) in the sense that villages are absent everywhere (towns in New England, counties or county subdivisions elsewhere); NCES not informative; NHGIS (a); QuickFacts (a), with a threshold effect that mimics (b).
- The earlier wording should be qualified in one respect. "Reference and labelling sources" support the line only for municipal counts (Wikipedia) and for Connecticut and New York labels (OSM, Nominatim, LAUS). The most widely used labelling source of all, the postal city name, labels Vermont addresses with the village and treats several town names as names to avoid. In Vermont the fold is therefore a choice against common address usage, defensible on governmental grounds (the town is the general-purpose municipality, and the ZIP named for the village covers the rest of the town anyway) but not on the ground that "people say the town".
- Practical consequence for the ICE use: with villages folded, the project needs an alias table from postal names to town cells for at least Bellows Falls and Saxtons River (Rockingham), Morrisville (Morristown), Enosburg Falls (Enosburgh), West Burke (Burke), Derby Line (Derby), Orleans (Barton), North Troy (Troy), Wells River (Newbury), Jeffersonville (Cambridge), Jacksonville (Whitingham), North Bennington (Bennington), Danielson (Killingly), Jewett City (Griswold) and Bantam (Litchfield). In NY and MI the reverse risk applies: a postal name equal to a village name does not place the address inside the village.
- Connecticut is the state where the fold best matches postal practice (town name always primary or accepted; three boroughs not valid postal names). Vermont is where it matches least. Michigan remains the weak leg on the "keep" side, as before, though USPS names Michigan villages more consistently (92 percent) than New York ones (74 percent).

### Gaps
- Still unchecked: Google geocoder output, voter-file vendors, QCEW, City Health Dashboard, the CDBG entitlement list, EDGE school district files, and what city string ICE records.
