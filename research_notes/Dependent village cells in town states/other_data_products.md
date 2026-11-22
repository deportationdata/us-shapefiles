# How data products outside Census core geography treat dependent incorporated places: VT villages and CT boroughs versus NY and MI villages (checked 17 Nov 2026)

Method notes for the report writer:
- "Direct" = I downloaded the source file or raw page text and tabulated or read it myself (OSM raw wikitext, Overpass extracts, Census PEP csv, Census of Governments xlsx, state NEU lists, BLS LAUS area file, Vermont Zoning Atlas repository, Nominatim and Census geocoder responses). Counts are my own tabulations of those files.
- "Via summariser" = page read through a summarising fetch tool; short quotes are exact, tables may be mis-transcribed.
- "Snippet" = from a web search result only; not opened.
- Essex Junction, VT is no longer a usable village example: Census PEP Vintage 2025, BLS LAUS and OSM all carry it as a city, separate from Essex town.

## 1. OpenStreetMap: what the wiki says and what the data actually has

### Takeaway
The earlier note is out of date for Michigan. Since June 2025 both OSM wiki tables put Michigan townships at admin_level 8 with villages at 9, the same shape as Vermont and Connecticut; only New York still has town = 7 and village = 8. The live data is mixed: CT boroughs are consistently 9, NY villages consistently 8, but Vermont villages are split 26 at level 9 / 17 at level 8 and Michigan villages are 235 at level 8 / 10 at level 9, so OSM is not a clean witness for "VT/CT fold, NY/MI keep".

### Cited Findings
- (Direct, raw wikitext) Table columns are admin_level 4 to 10, with the state name in column 4. Connecticut row: 5 n/a; 6 "Regional COG"; 7 n/a; 8 "Town"; 9 "City / Borough / Village"; 10 "In towns where these exist, Neighborhood". — [OSM wiki: United States admin level](https://wiki.openstreetmap.org/wiki/United_States_admin_level)
- (Direct) Vermont rows: 6 County; 8 "Town", 9 "In towns where these exist, incorporated Village"; separate rows 8 "City" (9 District, 10 Ward) and 8 "Gore". — [OSM wiki: United States admin level](https://wiki.openstreetmap.org/wiki/United_States_admin_level)
- (Direct) Vermont footnote: "Vermont has 37 incorporated villages ... Other villages and hamlets do not have separate government apart from their Town and have indistinct borders mostly defined by the expansion of water/sewer/sidewalk and similar services. These unincorporated areas should be mapped as a node without an admin_level tag." City footnote: "In Vermont, if a village becomes a city, it does not continue to overlay (be coterminous with) its parent town, but breaks away and becomes a completely separate municipality." — [OSM wiki: United States admin level](https://wiki.openstreetmap.org/wiki/United_States_admin_level)
- (Direct) Connecticut footnotes: "Towns in New England are municipal corporations..."; cities: "At one time, all New England cities were non-coextensive with their underlying town ... As with boroughs, many have also disincorporated and reverted to full town control", quoting Wikipedia that "the entire area of Connecticut is divided into towns, cities and boroughs are within town areas and their governments may or may not be consolidated with those of the towns in which they are located"; boroughs: "There are no legal restrictions in Connecticut that would prevent a city or borough today from overlaying the territory of more than one town". — [OSM wiki: United States admin level](https://wiki.openstreetmap.org/wiki/United_States_admin_level)
- (Direct) New York rows (outside NYC): 6 County; 7 "City" (8 "Ward, district, precinct"); 7 "Town" with 8 "Village" and 8 "Hamlet, City of Sherrill". Town footnote: "In New York, a 'Town' is effectively equivalent to an 'incorporated township' in other states." Village footnote: "Many Villages cross Town lines, but Village inhabitants are also all governed by some Town." — [OSM wiki: United States admin level](https://wiki.openstreetmap.org/wiki/United_States_admin_level)
- (Direct) The companion page disagrees on NY cities only: it lists New York 8 = "City / Hamlet", and 7 "Town" with 8 "Village". — [OSM wiki: United States/Boundaries](https://wiki.openstreetmap.org/wiki/United_States/Boundaries)
- (Direct) Michigan rows now read: 6 County; 7 n/a; 8 "Township / Charter Township" with 9 "Village"; 8 "City". Village footnote: "In Michigan, a village is subordinate to a township and can span more than one township. Villages can also span more than one county." City footnote: "After a forum discussion, participants agreed that non-overlapping city, town, and township boundaries should be commonly tagged at admin_level=8." — [OSM wiki: United States admin level](https://wiki.openstreetmap.org/wiki/United_States_admin_level)
- (Direct) The Boundaries page has the same Michigan layout (8 "Township / Charter township", 9 "Village"; 8 "City"); its edit log entry of 14 June 2025 reads "Township to level 8 and Village to level 9 as defined" on the admin level page. The admin level page was changed on 10 June 2025 ("Update table for WI, MI, and MN based on discussion"). — [OSM wiki: United States/Boundaries](https://wiki.openstreetmap.org/wiki/United_States/Boundaries)
- (Direct, forum JSON) The rationale for the June 2025 change: "in these four states, towns, cities, and townships, all form a single space-filling layer that fit together like a jigsaw puzzle. Therefore they should occupy the same admin_level value" (ZeLonewolf, 8 June 2025). On Michigan, one participant noted "in Michigan villages are included within the township as well" and another replied "there's nothing stopping a charter township ... from also containing a village ... Level 7 it is"; the proposer nonetheless closed with "there doesn't seem to be any disagreement on MI, WI, and MN, I've updated the United States Admin Level article". New York, Vermont and Connecticut are not discussed. — [OSM Community forum thread 131136](https://community.openstreetmap.org/t/admin-level-for-michigan-wisconsin-minnesota-and-north-dakota/131136)
- (Direct) General wiki rule: municipalities get admin_level 8, with the aside "(In some New England states, 'village' might be better tagged with admin_level=9, check the table above)". No rule is stated for when a village is 8 versus 9. — [OSM wiki: United States/Boundaries](https://wiki.openstreetmap.org/wiki/United_States/Boundaries)
- (Direct, Overpass extract of boundary=administrative relations at levels 7 to 9 inside each state, 17 Nov 2026) Vermont, 285 relations: level 8 = 220 town, 12 city, 17 village, 4 gore, 5 unorganized_town; level 9 = 26 village, 1 town. Examples: Woodstock village = 8; Swanton village = 8; Bellows Falls village = 9; Johnson has one village relation at 8 and another at 9; Essex Junction = 8 with border_type city. — [Overpass API](https://overpass-api.de/api/interpreter)
- (Direct, same extract) Connecticut, 182 relations: level 8 = 149 town, 20 city, 2 untyped (one is Fenwick); level 9 = 8 borough, 1 city (City of Groton), 2 village. Stonington, Litchfield, Bantam, Newtown, Jewett City, Danielson and Woodmont boroughs are all 9; their towns are 8. — [Overpass API](https://overpass-api.de/api/interpreter)
- (Direct, same extract) New York, 1,591 relations: level 7 = 928 town, 60 city, 5 borough, plus a handful of coterminous town-villages (Scarsdale is 7 with border_type "village;town"); level 8 = 527 village plus hamlets/CDPs. Village of Ossining = 8 and Town of Ossining = 7; Village of Kinderhook = 8 and Town of Kinderhook = 7. — [Overpass API](https://overpass-api.de/api/interpreter)
- (Direct, same extract) Michigan, 1,793 relations: level 8 = 1,199 township, 269 city, 235 village, 1 charter_township, 61 untyped; level 9 = 10 village, 12 untyped; level 7 = 1. Lake Orion, Holly, Milford and Beverly Hills villages are 9; most other villages are still 8, the same level as the township they sit in. — [Overpass API](https://overpass-api.de/api/interpreter)
- (Direct, Nominatim reverse geocodes) Point in Woodstock village VT: "Woodstock Village, Woodstock, Windsor County, Vermont" (address field village = "Woodstock Village"). Bellows Falls VT: "Bellows Falls, Rockingham, Windham County". Stonington borough CT: "Stonington, Southeastern Connecticut Planning Region" with town = "Stonington", city_district = "Stonington". Litchfield borough CT: town = "Litchfield", city_district = "Litchfield". Ossining NY: "Village of Ossining, Town of Ossining, Westchester County" (town field = "Village of Ossining"). Kinderhook NY: "Village of Kinderhook, Town of Kinderhook". Lake Orion MI: "Lake Orion, Oakland County" with no township. Holly MI: "Oakland County" only, no village or township. — [Nominatim](https://nominatim.openstreetmap.org/)

### Inferences
- The earlier claim "NY/MI villages at level 8 with towns at 7" now holds for New York only. On paper OSM groups Michigan with Vermont and Connecticut (village subordinate at 9); the stated reason for 8 versus 7 is whether towns and cities form one space-filling jigsaw, not whether villages are independent of towns.
- So OSM's line is drawn by the town/city relationship, and villages fall out as a by-product: where the town is the level-8 jigsaw piece, an overlapping village has to go to 9. It is not evidence that OSM mappers judged Michigan villages more town-like than New York ones.
- Michigan retagging of villages to 9 is about 4 percent done, and Vermont villages are about 60 percent at 9, so any pipeline reading OSM admin_level would get inconsistent village treatment inside both states.
- Nominatim output shows the practical effect: CT boroughs surface as a sub-district of the town, NY villages surface as the primary locality, VT villages surface as a village with the town alongside, MI is erratic.

### Gaps
- I did not find a wiki talk-page passage that states why NY towns stay at 7; the wiki only records it.
- The wiki says Vermont has 37 incorporated villages; the data has 43 village relations and other sources say 29 to 31. I did not reconcile these (dissolved villages probably remain mapped).

## 2. Census Population Estimates Program (subcounty / City and Town totals)

### Takeaway
No asymmetry. In the Vintage 2025 subcounty file, VT villages and CT boroughs are published exactly like NY and MI villages: a place record, a place-within-town record, and a "Balance of [town]" record.

### Cited Findings
- (Direct, sub-est2025.csv) Vermont: 256 county subdivisions (SUMLEV 061), 39 places (162: 29 villages, 10 cities), and 62 place-part/balance records (071: 29 village, 10 city, 23 "Balance of"). — [Census PEP sub-est2025.csv](https://www2.census.gov/programs-surveys/popest/datasets/2020-2025/cities/totals/sub-est2025.csv)
- (Direct) Connecticut: 169 county subdivisions, 30 places (19 cities, 10 boroughs, 1 "(balance)"), 37 SUMLEV 071 records (19 city, 10 borough, 7 "Balance of", 1 "(balance)"). — [Census PEP sub-est2025.csv](https://www2.census.gov/programs-surveys/popest/datasets/2020-2025/cities/totals/sub-est2025.csv)
- (Direct) New York: 1,009 county subdivisions, 594 places (532 villages, 62 cities), 1,070 SUMLEV 071 records (457 village, 155 village (pt.), 396 "Balance of", 62 city). Michigan: 1,540 county subdivisions, 533 places (253 villages, 280 cities), 893 SUMLEV 071 records (203 village, 107 village (pt.), 282 "Balance of", 301 city). — [Census PEP sub-est2025.csv](https://www2.census.gov/programs-surveys/popest/datasets/2020-2025/cities/totals/sub-est2025.csv)
- (Direct) Worked examples, 2025 estimates: Woodstock town VT 2,970 = Woodstock village 903 + Balance of Woodstock town 2,067. Rockingham town VT 4,697 includes Bellows Falls village 2,706 and a balance of 1,527. Stonington town CT 18,832 = Stonington borough 1,017 + balance 17,815. Litchfield town CT 8,381 = Litchfield borough 1,220 + Bantam borough 772 + balance 6,389. Ossining town NY 39,964 includes Ossining village 27,579 and a balance of 5,596. Orion charter township MI 38,882 = Lake Orion village 2,900 + balance 35,982. — [Census PEP sub-est2025.csv](https://www2.census.gov/programs-surveys/popest/datasets/2020-2025/cities/totals/sub-est2025.csv)

### Inferences
- Population denominators exist for both cell designs in all four states: the whole town (061), the village/borough (162) and the town remainder (071 balance). Choosing "fold" in VT/CT does not lose a join that "split" would have had, and vice versa.

### Gaps
- None for this question.

## 3. Census of Governments / Government Finance

### Takeaway
No asymmetry. VT villages and CT boroughs are active "municipal" governments with their own Census government IDs, the same type code as NY and MI villages; the towns around them are "township" governments in all four states.

### Cited Findings
- (Direct, 2022 Government Units listing, General Purpose sheet) Vermont: 235 active towns (type "3 - TOWNSHIP"), 30 active villages and 10 cities (type "2 - MUNICIPAL"), 14 counties. — [Census of Governments 2022 Government Units file](https://www2.census.gov/programs-surveys/gus/datasets/2022/govt_units_2022.ZIP)
- (Direct) Connecticut: 148 active towns (TOWNSHIP), 20 cities and 10 boroughs (MUNICIPAL). — [Census of Governments 2022 Government Units file](https://www2.census.gov/programs-surveys/gus/datasets/2022/govt_units_2022.ZIP)
- (Direct) New York: 929 active towns (TOWNSHIP), 533 villages and 62 cities (MUNICIPAL). Michigan: 1,110 townships and 130 charter townships (TOWNSHIP), 253 villages and 280 cities (MUNICIPAL). — [Census of Governments 2022 Government Units file](https://www2.census.gov/programs-surveys/gus/datasets/2022/govt_units_2022.ZIP)
- (Direct) Example units with separate IDs and populations: "VILLAGE OF WOODSTOCK" VT (pop 930) and "TOWN OF WOODSTOCK" VT (3,034); "BOROUGH OF STONINGTON" CT (990) and "TOWN OF STONINGTON" CT (18,427); "BOROUGH OF BANTAM" CT (760); "VILLAGE OF OSSINING" NY (27,298) and "TOWN OF OSSINING" NY (39,742); "VILLAGE OF LAKE ORION" MI (2,895) and "CHARTER TOWNSHIP OF ORION" MI (38,304). — [Census of Governments 2022 Government Units file](https://www2.census.gov/programs-surveys/gus/datasets/2022/govt_units_2022.ZIP)

### Inferences
- In this file the town population is the whole town including the village or borough in all four states (Woodstock town 3,034, Stonington town 18,427, Ossining town 39,742, Orion township 38,304), so government-finance per-capita figures for towns are on a whole-town basis everywhere; a "town remainder" cell does not match the finance unit in NY or MI either.
- Finance data keyed to these IDs (Census of Governments finance files, and the Government Finance Database built on them) therefore exists for VT villages and CT boroughs as separate units, to the extent they were sampled or enumerated.

### Gaps
- I did not open the individual-unit finance files to confirm that the small VT villages and CT boroughs have non-missing finance records in a given year.

## 4. Treasury ARPA non-entitlement units (NEU)

### Takeaway
No asymmetry. All four states' NEU lists give villages and boroughs their own rows and allocations, and the town or township row carries only the remainder population.

### Cited Findings
- (Direct, earlier round, verbatim) Treasury's rule: "In states in which MCDs overlap with incorporated places and/or consolidated cities, the Census Bureau's 'MCD Place Part' was used as the population of the respective subcomponents of the MCD." — [Treasury NEU Methodology](https://home.treasury.gov/system/files/136/NEU_Methodology.pdf)
- (Direct, state open data, 278 rows) Vermont's list has 237 "Town" rows, 32 "Village" rows and 9 "City" rows. Woodstock Town is listed with 2019 population 2,062 and Woodstock Village separately with 858; Swanton Town 4,179 and Swanton Village 2,375; Johnson Town 2,126 and Johnson Village 1,507; Rockingham Town 1,477 and Bellows Falls Village 2,965; Essex Town 11,038 and Essex Junction Village 10,852. Each row has its own NEU amount and county-share amount. — [Vermont open data: ARPA Local Fiscal Recovery Fund Payments](https://data.vermont.gov/d/ijr8-p554)
- (Direct, PDF) Connecticut OPM's Tranche 2 town-by-town sheet lists the 169 towns and then separate rows coded 501 and 601 to 611: Groton city, Bantam borough, Danielson borough, Fenwick borough, Groton Long Point borough, Jewett City borough, Litchfield borough, Newtown borough, Stonington borough, Woodmont borough. Stonington borough's NEU pass-through is $44,956.84 against Stonington town's $898,882.53; Litchfield borough $61,281.66 and Bantam borough $36,972.42 against Litchfield town $313,375.62; Fenwick borough $2,288.52. — [CT OPM ARPA SLFRF Tranche 2 town by town](https://portal.ct.gov/-/media/opm/coronavirus/arpa-slfrf-july-2022-town-by-town.pdf)
- (Direct, PDF) An earlier congressional estimate sheet also lists "Stonington borough" and "Stonington town", "Groton city", "Groton town", "Groton Long Point borough", "Danielson borough", "Jewett City borough" and "Fenwick borough" as separate lines. — [CT-02 non-entitlement estimates, House draft](https://courtney.house.gov/sites/evo-subsites/courtney-evo.house.gov/files/CT-02%20Non%20entitlement%20estimates%20-%20House%20draft%20American%20Rescue%20Plan.pdf)
- (Direct, PDF) New York's list has a "Class" column of Town or Village: e.g. "Village of Ossining ... 2,544,812.87" and "Town of Ossining ... 568,203.42"; "Village of Kinderhook 115,281.70", "Village of Valatie 188,819.94", "Town of Kinderhook 531,690.71". — [NY Open Budget: Local ARPA NEU allocations](https://openbudget.ny.gov/covid-funding/localarpa/local-ARPA-NEU-allocations.pdf)
- (Direct, PDF) Michigan Treasury's list of 1,724 NEUs gives "Holly Township" population 5,538 and "Holly Village" 6,149; "Orion Charter Township" 36,627 and "Lake Orion Village" 3,189. — [Michigan Treasury NEU allocations, 17 June 2021](https://www.michigan.gov/documents/treasury/Non_Entitlement_Allocations_6.17.2021_728154_7.pdf)
- (Snippet) Michigan Municipal League reported that an updated federal list recognised all Michigan villages as distinct NEUs eligible for their own per-capita allocation. — [MML Inside 208](https://mml.org/inside208/new-arp-guidance-for-non-entitlement-units-released/)

### Inferences
- The populations are remainders in every state: Woodstock Town 2,062 + Village 858 is about the whole town; Orion township 36,627 + Lake Orion 3,189 is about the whole township; Town of Ossining's allocation is about a fifth of the village's although the whole town is larger than the village; Litchfield town's allocation is consistent with the town minus its two boroughs.
- Treasury's NEU list is the one federal programme that actually paid money on a non-overlapping "village plus town remainder" partition, and it applied that partition to VT villages and CT boroughs as well as NY and MI villages. On this evidence the federal precedent is the symmetric split, not the project's asymmetry.

### Gaps
- Vermont's count of 32 village rows is higher than the 30 villages in the 2022 Census of Governments; I did not identify the extra rows.
- I could not find a Treasury-hosted national NEU list (several guessed file names returned 404); the state lists were used instead.

## 5. FBI UCR / Crime Data Explorer and LEAIC

### Takeaway
Crime data follows police agencies, not a geography rule, so it is inconsistent rather than asymmetric: a VT village or CT borough appears as a "city" only if it runs its own police department, and the same is true of NY and MI villages. I could only check VT and CT directly.

### Cited Findings
- (Via summariser) FBI 2019 Table 8 for Vermont lists 52 "cities". It includes the villages Bellows Falls (population 2,988) and Lyndonville (1,160) as their own rows, with no Rockingham row; it lists Woodstock at 2,925, Swanton at 6,595, Northfield at 5,990, Ludlow at 1,876, Manchester at 4,242 and Essex at 22,213. — [FBI Crime in the U.S. 2019, Table 8, Vermont](https://ucr.fbi.gov/crime-in-the-u.s/2019/crime-in-the-u.s.-2019/tables/table-8/table-8-state-cuts/vermont.xls)
- (Via summariser) FBI 2019 Table 8 for Connecticut lists 94 "cities". It has "Groton" (8,967), "Groton Long Point" (509) and "Groton Town" (29,046) as three rows, "Naugatuck" (31,214), and a single "Stonington" row at 18,439. Stonington borough, Litchfield borough, Jewett City and Danielson do not appear. — [FBI Crime in the U.S. 2019, Table 8, Connecticut](https://ucr.fbi.gov/crime-in-the-u.s/2019/crime-in-the-u.s.-2019/tables/table-8/table-8-state-cuts/connecticut.xls)
- (Snippet) LEAIC links each agency's ORI to FIPS state, county and place codes and to the Census government ID and name; the documented join is UCR to LEAIC by ORI, then to Census data by FIPS state and place code. — [ICPSR: About the LEAIC](https://www.icpsr.umich.edu/web/pages/NACJD/guides/leaic.html)

### Inferences
- The Vermont populations show three different coverage bases in one table: village only (Bellows Falls 2,988, close to the village's NEU population of 2,965), whole town (Woodstock 2,925 and Swanton 6,595 match town plus village), and Essex 22,213 (town plus Essex Junction). Connecticut's Stonington row at 18,439 is the whole town including the borough, while Groton is split three ways (city, Groton Long Point, town remainder 29,046).
- For joining crime counts, the whole town is the safer unit in VT and CT: most rows are whole-town agencies, and the few village or borough agencies can be summed up to the town. A village cell would have no matching crime row in most cases.

### Gaps
- NY and MI Table 8 pages were not opened, so the claim that NY and MI village police departments appear as their own rows is expected but unverified here.
- I could not query the Crime Data Explorer agency API (the request was blocked in this environment) and did not open the LEAIC codebook, so I cannot say how LEAIC codes the place FIPS for a town-wide agency in New England.

## 6. Elections and voter files

### Takeaway
I found no source showing villages or boroughs as reporting units for state or federal elections in any of the four states; they matter only for their own local elections. The evidence here is thin and mostly from search snippets.

### Cited Findings
- (Snippet) Vermont results are reported town by town: media maps are built from "town-by-town results from the Vermont Secretary of State's office", and the Secretary of State's turnout file is laid out by town name and district. — [VTDigger, 6 Nov 2024](https://vtdigger.org/2024/11/06/town-by-town-election-results-how-vermonters-voted-in-key-races-on-tuesday/); [Vermont SOS 2024 general election turnout](https://outside.vermont.gov/dept/sos/Elections%20Division/election%20info%20and%20resources/elections%20results%20and%20data/2024%20General%20Election%20Voter%20Turnout-1.pdf)
- (Snippet) Connecticut boroughs hold their own elections, "biennially, odd years, first Monday in May" per the Secretary of the State's register manual; Stonington borough's charter lets anyone vote "who is then qualified to vote in Town of Stonington elections and resides within the borough". — [CT SOTS Register Manual: Towns, Cities, and Boroughs](https://portal.ct.gov/SOTS/Register-Manual/Section-VII/Town-Elections); [Stonington Borough charter page](https://www.stoningtonboroughct.gov/copy-of-1862-petition-to-the-state-as)
- (Snippet) Michigan: "A village shall hold its regular election for a village office at the general election and the appropriate township clerk shall conduct the election." — [MCL 168.642](https://codes.findlaw.com/mi/chapter-168-michigan-election-law/mi-comp-laws-168-642/)
- (Snippet) New York village elections are usually separate March elections; one county official said the county Board of Elections runs them only on request, and villages publish their own clerk-certified results. — [WAMC, 21 Mar 2024](https://www.wamc.org/news/2024-03-21/election-results-in-new-york-villages-are-in); [Wellsville Sun](https://wellsvillesun.com/?p=12977)

### Inferences
- In all four states the town or township (or city) is the election-administration unit for state and federal contests, and village or borough residents are town electors. Election data therefore joins to the whole town everywhere and gives no support for treating NY/MI villages differently from VT/CT ones.
- Michigan is, if anything, closer to the VT/CT pattern here: the township clerk runs even the village's own election.

### Gaps
- No official statement was opened for any state saying that villages or boroughs are not reporting units; this is inferred from how results are published.
- NY and MI precinct result layouts (election districts within towns; precincts within cities and townships) were not checked directly, nor were voter-file vendors' locality fields.

## 7. BLS LAUS and other federal series (HUD, QCEW, NCES, ACS)

### Takeaway
BLS LAUS is the one federal series found that draws the project's line: in Vermont and Connecticut it publishes towns only, with no villages or boroughs, while in New York it publishes large villages as their own areas alongside towns. Michigan has no villages in LAUS, but only because none reaches 25,000.

### Cited Findings
- (Via summariser) LAUS publishes "cities of 25,000 population or more" and "cities and towns in New England regardless of population". — [BLS LAUS geography](https://www.bls.gov/lau/laugeo.htm)
- (Direct, la.area file; area type G = "Cities and towns above 25,000 population", H = "Cities and towns below 25,000 population in New England") Vermont has 252 entries: 240 towns, 2 gores and 10 cities. There are no village entries: Woodstock town and Rockingham town appear, Woodstock village and Bellows Falls do not. — [BLS LAUS la.area](https://download.bls.gov/pub/time.series/la/la.area); [la.area_type](https://download.bls.gov/pub/time.series/la/la.area_type)
- (Direct) Connecticut has exactly 169 entries, all towns (labelled "town", "city/town", or "Naugatuck borough/town"). No dependent borough appears: Stonington town and Litchfield town are listed, the boroughs are not. — [BLS LAUS la.area](https://download.bls.gov/pub/time.series/la/la.area)
- (Direct) New York has 107 type-G entries: 67 towns, 29 cities, and 10 villages listed in their own right: Freeport, Hempstead, Kiryas Joel, Lindenhurst, Ossining, Port Chester, Rockville Centre, Spring Valley and Valley Stream villages, plus "Harrison village/town". Both "Ossining town, NY" (code CS3655541000000) and "Ossining village, NY" (CT3655530000000) are present. — [BLS LAUS la.area](https://download.bls.gov/pub/time.series/la/la.area)
- (Direct) Michigan has 88 type-G entries: 51 cities, 30 townships (for example "Orion charter township, MI") and 7 county-part entries; no villages. — [BLS LAUS la.area](https://download.bls.gov/pub/time.series/la/la.area)
- (Direct) The largest Michigan village rows seen in the files used here are far below the threshold (Holly Village 6,149; Lake Orion 2,900 to 3,189). — [Michigan Treasury NEU allocations](https://www.michigan.gov/documents/treasury/Non_Entitlement_Allocations_6.17.2021_728154_7.pdf)
- (Direct) The Census geocoder returns both layers for a point in each kind of village: "Woodstock village" + "Woodstock town"; "Stonington borough" + "Stonington town"; "Ossining village" + "Ossining town"; "Lake Orion village" + "Orion charter township". — [Census Geocoder](https://geocoding.geo.census.gov/geocoder/)

### Inferences
- LAUS's New England rule is "every city and town", which is a town-only partition of VT and CT; a village or borough cell there has no LAUS series, and a town-remainder cell would not match the whole-town series.
- LAUS in New York publishes a village and its enclosing town as overlapping areas (Ossining town includes Ossining village), so it supports "village is a recognised unit in NY" but not a town-remainder unit.
- LAUS does not distinguish Michigan from Vermont on principle; the absence of Michigan villages is a population-threshold effect.

### Gaps
- HUD (CDBG entitlement lists, FMR areas), QCEW, NCES and ACS were not re-checked this round. The earlier notes in "US municipality cells from Census units" cover HUD and ACS in general terms but not the village/borough question; nothing here verifies them.
- I did not confirm from a BLS statement that New England villages and boroughs are deliberately excluded; it is read off the area list.

## 8. Geocoders and postal addresses

### Takeaway
Nominatim returns the town as the locality for CT boroughs, the village as the locality for NY villages, and the village with the town beside it for VT villages. I have no verified USPS or Google results.

### Cited Findings
- (Direct) Nominatim reverse geocodes are listed in section 1: CT borough points return town = "Stonington" / "Litchfield" with the borough as city_district; NY points return "Village of Ossining, Town of Ossining" and "Village of Kinderhook, Town of Kinderhook"; VT points return "Woodstock Village, Woodstock" and "Bellows Falls, Rockingham"; MI points return "Lake Orion, Oakland County" or the county only. — [Nominatim](https://nominatim.openstreetmap.org/)
- (Direct) The Census geocoder returns place and county subdivision as two separate layers in all four states and does not choose between them. — [Census Geocoder](https://geocoding.geo.census.gov/geocoder/)

### Inferences
- For the project's use (naming the city or town of an arrest), an OSM-based geocoder would already label CT borough addresses with the town and NY village addresses with the village, matching the project's choice in those two states. Vermont is ambiguous (both names returned) and Michigan loses the township.

### Gaps
- USPS city names and Google geocoder output were not tested; no source was opened. I found no reliable source on which name ICE or other agencies record for addresses in these places.

## 9. Wikipedia and state-style lists of municipalities

### Takeaway
Wikipedia's lists do draw the project's line, with Michigan on the "village counts" side: Vermont and Connecticut count towns and cities only, while New York and Michigan count villages as municipalities.

### Cited Findings
- (Direct, API extract) "The U.S. state of Vermont is divided into 247 municipalities, including 237 towns and 10 cities ... As of 2024, Vermont has 30 incorporated villages, which are municipal governments operating within a town and providing additional services." — [Wikipedia: List of municipalities in Vermont](https://en.wikipedia.org/wiki/List_of_municipalities_in_Vermont)
- (Direct) "The U.S. state of Connecticut is divided into 169 municipalities, including 19 cities, 149 towns and one borough" (the one borough being Naugatuck, a consolidated borough-town). "All cities in Connecticut are dependent municipalities, meaning they are located within and subordinate to a town." — [Wikipedia: List of municipalities in Connecticut](https://en.wikipedia.org/wiki/List_of_municipalities_in_Connecticut)
- (Direct) "This is a list of municipalities in New York other than towns, which includes all 532 villages and 62 cities of New York State." — [Wikipedia: List of municipalities in New York](https://en.wikipedia.org/wiki/List_of_municipalities_in_New_York)
- (Direct) "Michigan ... contains 1,774 municipalities consisting of 276 cities, 258 villages, and 1,240 townships ... Cities are not subject to a township's jurisdiction, but villages remain part of the township in which they are located; village residents pay both township and village taxes, and share services with the township. Since all Michigan residents who do not live in a city live in a township, a village's population is counted in the population of the township in which it is located." — [Wikipedia: List of municipalities in Michigan](https://en.wikipedia.org/wiki/List_of_municipalities_in_Michigan)

### Inferences
- "247 municipalities" in Vermont and "169 municipalities" in Connecticut are the standard counts, and both exclude dependent villages and boroughs. New York and Michigan headline counts include villages. This is the clearest reference-source support for the asymmetry.
- Wikipedia's Michigan text also states the counter-argument: the village population is counted in the township, exactly as in Vermont.

### Gaps
- Official state lists (Vermont Secretary of State, Connecticut OPM, New York Department of State, Michigan) were not opened this round; the earlier state-practice notes cover them.

## 10. Researcher and practitioner "municipality" layers; zoning jurisdiction

### Takeaway
Zoning atlases show that some VT villages and CT sub-town units do regulate their own land, so "the town is the only regulator" is not strictly true in either state. The one practitioner layer checked (CommunityScale) uses county subdivisions in all twelve strong-MCD states and so folds villages into towns in NY and MI as well as VT and CT.

### Cited Findings
- (Via summariser) National Zoning Atlas treats a jurisdiction as any government with zoning power: "cities, towns, counties, villages, and other places that can exercise zoning"; the page says nothing about nested villages or boroughs. — [National Zoning Atlas: How](https://www.zoningatlas.org/how)
- (Via summariser) Connecticut: the atlas analysed "all 187 zoning jurisdictions (i.e., cities, towns, villages, and private associations)". — [National Zoning Atlas: Connecticut](https://www.zoningatlas.org/connecticut)
- (Snippet) Connecticut statute: a town zoning commission has jurisdiction over the part of the town outside any city or borough, and a borough may by ordinance have the town commission act for it. — [Conn. Gen. Stat. chapter 124](https://cga.ct.gov/2025/pub/chap_124.htm)
- (Via summariser) Vermont Zoning Atlas data dictionary: jurisdiction field JXTN is "Name of town, city or incorporated village per the VT Geographic Area Names and Codes Standard", and "VCGI plans a combined town/village code (TVGEOID)". — [Vermont Zoning Atlas: data](https://verso-uvm.github.io/Vermont-Zoning-Atlas/data.html)
- (Direct, repository file list and three regional files) The Vermont atlas has separate jurisdiction files or JXTN values for some villages: "Woodstock Town" and "WoodstockVillage"; "HydeParkTown" and "HydeParkVillage"; "LudlowTown" and "LudlowVillage"; "Manchester" and "ManchesterVillage"; "Stowe Town" and "Stowe Village"; "Enosburgh" and "Enosburghfalls". Others are joint or town-only: "JohnsonTownJohnsonVillage", "Morristown_Morrisville", and a single "Rockingham" with no Bellows Falls entry; Swanton, Lyndon, Northfield and Waterbury have one file each. — [Vermont Zoning Atlas repository](https://github.com/Verso-UVM/Vermont-Zoning-Atlas)
- (Snippet) Vermont examples of both arrangements: Manchester Village has a standalone zoning bylaw; Barton proposed a joint bylaw for the town and its villages; Plainfield's charter folds the village's regulations into the town ordinance. — [Manchester Village zoning bylaw, Dec 2023](https://outside.vermont.gov/agency/ACCD/bylaws/Bylaws%20and%20Plans%20Approved/ManchesterVillage_Adopted_ZoningBylaw_December_2023.pdf); [Barton/Orleans proposed bylaws](https://outside.vermont.gov/agency/ACCD/bylaws/Bylaws%20and%20Plans%20Approved/BartonOrleans_Proposed_Plan_and_Bylaws_March_2016.pdf)
- (Via summariser) CommunityScale: in strong-MCD states "(Connecticut, Maine, Massachusetts, Michigan, Minnesota, New Hampshire, New Jersey, New York, Pennsylvania, Rhode Island, Vermont, Wisconsin)" municipalities are "county subdivisions (towns/townships that function as governments)"; "Where a place and a coterminous county subdivision both exist for the same locality, the county subdivision is used." It does not mention villages or boroughs inside towns. — [CommunityScale docs: Geographic layers](https://communityscale-docs.pages.dev/docs/geographic-layers)

### Inferences
- Connecticut's 187 zoning jurisdictions exceed its 169 towns by 18, so some boroughs, the City of Groton and private associations must be counted as their own zoning jurisdictions. The source does not name them.
- In Vermont roughly a handful of the 30 or so villages have their own zoning in the atlas and the rest are covered jointly with or by the town, so village land-use autonomy is real but a minority pattern.
- CommunityScale's county-subdivision rule gives whole towns in all four states. It agrees with the project in VT and CT and disagrees in NY and MI, where the project keeps villages separate.

### Gaps
- NZA jurisdiction lists for New York and Michigan were not opened, so the comparison "VT/CT sub-town units sometimes zone; NY/MI villages always zone" is not established here.
- City Health Dashboard, Urban Institute, IPUMS NHGIS guidance, Trounstine, the Wharton survey and Destination Health were not checked this round. The earlier notes (academic_practice.md, other_datasets_and_tools.md) discuss several of them in general terms but not the VT/CT versus NY/MI village question, and I did not re-verify them.
- The list of which 18 Connecticut sub-town units have their own zoning was not found.

## Overall reading across products (for the report writer)

### Takeaway
"Town is the unit in VT/CT, village is a unit in NY/MI" is a recognised convention in reference and labelling sources (Wikipedia municipality counts, BLS LAUS for New York, OSM for New York and Connecticut) but not in federal data that enumerates governments or pays them: Census PEP, the Census of Governments and Treasury's NEU lists treat VT villages and CT boroughs exactly like NY and MI villages. Michigan is the weak leg of the asymmetry: OSM's wiki now groups it with Vermont and Connecticut, LAUS has no Michigan villages, and township clerks run village elections.

### Cited Findings
- Summary of the sections above; every underlying fact is cited there.

### Inferences
- Products that split villages out with a town remainder, symmetric across all four states: Census PEP (SUMLEV 071), Treasury NEU.
- Products that list villages and boroughs as separate governments but keep the town whole (overlapping), symmetric: Census of Governments, Census geocoder, ACS-style place and county subdivision layers.
- Products that are town-only in VT/CT and carry villages in NY: BLS LAUS (overlapping with the town), Wikipedia counts, Nominatim labels, OSM tagging for CT and NY.
- Products that are whole-town everywhere: election reporting (as far as checked), CommunityScale.
- Products with no rule: FBI crime tables (agency-driven), zoning atlases (jurisdiction-driven; some VT villages and CT sub-town units are separate).
- The asymmetry is defensible as a naming and policy choice (what people and reference sources call the municipality) rather than as a data-availability choice: no join checked here is possible only under the asymmetric design, and the Treasury precedent points to a symmetric split.

### Gaps
- Not checked at all this round: HUD, QCEW, NCES, City Health Dashboard, NHGIS, USPS, Google, voter-file vendors, NY and MI FBI tables, NY and MI zoning atlases.
