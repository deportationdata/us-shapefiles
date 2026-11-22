# Village and borough police agencies in Vermont, Connecticut, New York and Michigan

Retrieved 17 November 2026. Counts were made programmatically from downloaded agency lists; scripts and intermediate files are in `/private/tmp/claude-501/-Users-graeme--claude-spares-spare-nsjsKl/8d76e247-022c-4fc8-b950-c1098d762aeb/scratchpad/police/` (`scripts/*.R`, `cde_agencies.csv`, `cde_NY_classified.csv`, `cde_MI_village.csv`, `pe_summary.csv`, `ny/dcjs_village_2023_2025.csv`). Denominators are the village/borough rows in `data/places-sf.parquet`: VT 30 villages, CT 10 boroughs (the 8 separate boroughs plus Naugatuck and Groton Long Point), NY 532 villages, MI 253 villages.

Summary table (derivations in the sections below):

| State | Dependent units | Units with their own police agency | Share | Basis |
|---|---|---|---|---|
| Vermont | 30 villages | 3 (Bellows Falls, Swanton, Woodstock) | 10% | FBI list (53 municipal agencies) plus municipal sources on who runs each |
| Connecticut | 8 separate boroughs | 0 | 0% | FBI list (95 municipal agencies), 2018 resident-trooper list |
| Connecticut | 10 Census boroughs | 1 (Groton Long Point); Naugatuck is a consolidated town-borough department | 10% | FBI list |
| New York | 532 villages | 212 reporting in 2025 (DCJS); 226 reporting in 2023-25 (DCJS); 232 on the FBI list | 40% to 44% | DCJS personnel file; FBI list |
| Michigan | 253 villages | 89 on the FBI list (76 with 2025 employee data), plus 3 villages in joint agencies | 30% to 36% | FBI list, name match |

## 1. FBI Crime Data Explorer: which villages and boroughs appear as agencies?

### Takeaway
The FBI agency list answers the question directly for all four states: it names 5 of Vermont's 30 villages (only 3 of which are village-run), 1 of Connecticut's 10 Census boroughs (Groton Long Point) plus the City of Groton, 232 New York village departments (plus 9 joint town-and-village departments) and 89 Michigan village departments. New York and Michigan come out close to each other (about 35 to 44 percent of villages), Vermont at 10 percent and the eight separate Connecticut boroughs at zero.

### Cited Findings

Method. The CDE agency endpoint works without an API key. I downloaded the four state lists and, for 416 candidate agencies, the police-employee series for 2019 to 2025 (officer counts and "Participated Population", the same Police Employee collection that feeds Crime in the U.S. Table 78). All FBI municipal agencies carry `agency_type_name = "City"` regardless of whether they are a city, town, township or village, so village agencies had to be identified by name.

- Agency counts by FBI type: VT 87 agencies, of which 53 "City"; CT 108, of which 95 "City"; NY 537, of which 420 "City"; MI 654, of which 439 "City". — [FBI CDE agency list, VT](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/VT); [CT](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/CT); [NY](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/NY); [MI](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/MI)

Vermont (exact match of the agency name stem against the 30 village names).

- Five of the 30 village names appear as agencies: "Bellows Falls Police Department" (VT0130100), "Ludlow Police Department" (VT0140100), "Manchester Police Department" (VT0020400), "Swanton Police Department" (VT0060300) and "Woodstock Police Department" (VT0140500). Two more relate to villages under another name: "Morristown Police Department" (VT0080100; Morrisville village lies in Morristown) and "Lyndonville Police Department" (VT0030200; village dissolved 2023). No agency exists for the other 25 villages, including Enosburg Falls, Derby Line, Johnson, Orleans, Barton, Poultney and North Bennington. — [FBI CDE agency list, VT](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/VT)
- The population the FBI assigns to each agency in 2025 shows which geography it treats the agency as covering: Bellows Falls 2,728 (the village; 7 officers); Swanton 6,878 (the whole town; 8 officers); Woodstock 3,009 (the whole town; 6 officers); Ludlow 2,163 (the whole town; 6 officers); Manchester 4,458 (the whole town; 10 officers); Morristown 6,269 (the whole town; 15 officers); Lyndonville 1,219 (about the former village; 4 officers). — [FBI CDE police employee data, e.g. Bellows Falls](https://cde.ucr.cjis.gov/LATEST/pe/agency/VT0130100?from=2019&to=2025); [Woodstock](https://cde.ucr.cjis.gov/LATEST/pe/agency/VT0140500?from=2019&to=2025); [Swanton](https://cde.ucr.cjis.gov/LATEST/pe/agency/VT0060300?from=2019&to=2025)
- 52 of the 53 Vermont municipal agencies reported 2025 employee data (Weathersfield last reported for 2024). — same endpoint, all 53 ORIs.

Connecticut (match against the 10 borough names).

- Agencies carrying a borough's name: "Groton Long Point Police Department" (CT00B5900; 6 officers, population 520 in 2025), "Naugatuck Police Department" (consolidated town-borough; population 32,273), "Newtown Police Department" (population 28,283, the town), "Stonington Police Department" (population 18,900, the town). No agency is named for Bantam, Danielson, Fenwick, Jewett City, Litchfield or Woodmont. — [FBI CDE agency list, CT](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/CT); [Groton Long Point employee data](https://cde.ucr.cjis.gov/LATEST/pe/agency/CT00B5900?from=2019&to=2025)
- Groton has three separate FBI agencies: "Groton Police Department" (CT0005900; 28 officers, population 10,378, i.e. the City of Groton), "Groton Town Police Department" (CT00A5900; 63 officers, population 27,977) and Groton Long Point. — [FBI CDE, Groton City](https://cde.ucr.cjis.gov/LATEST/pe/agency/CT0005900?from=2019&to=2025); [Groton Town](https://cde.ucr.cjis.gov/LATEST/pe/agency/CT00A5900?from=2019&to=2025)

New York (name pattern: agency name contains "Village", plus plain "X Police Department" where X is a Census village name and not a city name).

- 227 agencies are named "X Village Police Department" (223 match a Census village name directly; 4 more, Athens, Angelica, Brownville and Norwood, match once a double space in the FBI name is removed). Five more village departments have no "Village" in the name: Muttontown, Brookville, Brewster, Black River, Ellicottville. Total 232 village agencies, against 532 villages = 43.6 percent. — [FBI CDE agency list, NY](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/NY)
- A further 9 are joint "X Town and Village Police Department" agencies (Macedon, Webster, New Hartford, New Paltz, Lewiston, Addison, Camillus, Waterford, Nunda), and "Lakewood-Busti Police Department" is a village-town joint agency. 113 agencies are named "X Town Police Department". — same source.
- Activity check: of the 232 village agencies, 196 have 2025 employee data and 222 have 2024 or 2025 data. The ten with nothing after 2023 are Athens, Youngstown, Bath, Ocean Beach, Afton, Bainbridge, Watkins Glen, Whitehall, Sleepy Hollow and Dolgeville; several of these (Athens, Youngstown, Afton, Bainbridge) last reported zero officers, which suggests defunct ORIs, while Sleepy Hollow (30 officers in 2022) is plainly a reporting gap. Some agencies that do report show zero officers (e.g. Corfu, Brownville, Oriskany, Angelica). — [FBI CDE police employee endpoint, e.g. Sleepy Hollow lookup pattern](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/NY)
- Only 77 of the 237 NY village-type agencies are flagged `is_nibrs = true`, so incident-level FBI data covers a minority of them. — same source.

Michigan (name pattern: "X Police Department" where X equals a Census village name and no Michigan city has that name; FBI names carry no "Village" label).

- 89 agencies match: Akron, Almont, Armada, Augusta, Bancroft, Baraga, Barryton, Bellaire, Bellevue, Beverly Hills, Birch Run, Blissfield, Capac, Carleton, Cass City, Cassopolis, Central Lake, Chesaning, Clinton, Colon, Constantine, Decatur, Deckerville, Dundee, Eau Claire, Elk Rapids, Elkton, Elsie, Fowlerville, Franklin, Freeport, Gagetown, Galien, Hesperia, Holly, Kalkaska, Kinde, Kingston, L'Anse, Lake Linden, Lake Odessa, Lake Orion, Lakeview, Laurium, Lawrence, Lawton, Lennon, Lexington, Mackinaw City, Mancelona, Mattawan, Mayville, Mendon, Milford, Millington, Morrice, Nashville, New Era, New Lothrop, Oakley, Otisville, Owendale, Oxford, Paw Paw, Peck, Pentwater, Pigeon, Pinckney, Port Austin, Quincy, Reese, Richland, Romeo, Rothbury, Schoolcraft, Sebewaing, Shelby, Shepherd, South Rockwood, Sparta, St. Charles, Stockbridge, Three Oaks, Ubly, Union City, Vicksburg, Walkerville, White Pigeon, Wolverine Lake. 89 of 253 = 35.2 percent. — [FBI CDE agency list, MI](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/MI)
- Three more villages are policed by joint agencies named for them: "Ontwa Township-Edwardsburg Police Department" and "Grand Beach/Michiana Police Department" (two villages). Counting them gives 92 of 253 = 36.4 percent. — same source.
- Activity check: 76 of the 89 have 2025 employee data, 81 have 2024 or 2025 data, 7 last reported for 2023 (Freeport, Bellevue, Bellaire, Baraga, Galien, Oakley, Gagetown; Freeport and Gagetown with zero officers) and Deckerville has none in 2019-2025. Restricting to agencies with 2025 data gives 76 of 253 = 30.0 percent. — [FBI CDE police employee endpoint](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/MI)
- The median FBI population for the 89 is 1,425; seven exceed 4,000 (Milford 17,751, Beverly Hills 10,542, Dundee 6,176, Holly 5,980, Wolverine Lake 4,504, Sparta 4,343, Vicksburg 4,013). Milford's figure is far above the village's size, indicating the village department also covers the township. — same endpoint.
- 99 Michigan agencies are named "X Township Police Department"; 13 of them share a name with a village (e.g. Oxford Township, Dryden Township, Metamora Township, Springport Township) and were not counted as village agencies. — [FBI CDE agency list, MI](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/MI)

### Inferences
- Confirms the earlier notes for Vermont ("two or three" village forces; the count is 3 of 30) and Connecticut (0 of 8 separate boroughs; Groton City and Groton Long Point the exceptions). Refines New York: the earlier "at least 20 percent and probably 40 to 50 percent" becomes 40 to 44 percent, so the lower half of that range. Fills the Michigan gap: 30 to 36 percent, which the earlier notes left as "unknown, likely a substantial minority". It also verifies the statement in `other_data_products.md` that NY and MI village departments appear as their own FBI rows.
- The policing contrast is real but is a contrast of degree in both directions: roughly 60 percent of New York villages and 65 percent of Michigan villages have no police agency of their own either. Michigan (about a third) sits much closer to New York than to Vermont.
- Because the FBI labels every municipal agency "City" and gives Swanton, Woodstock and Ludlow the whole town's population, FBI data alone cannot tell a village department from a town department; the name and the served population have to be read together with local sources.
- The Michigan count rests on a name match. It could overcount where a township department is named without the word "Township", and undercount villages policed by a same-named township department. The population check found no obvious false positives.

### Gaps
- The Crime in the U.S. Table 8 and Table 78 spreadsheets themselves (2019 and latest) were not downloaded; the CDE police-employee endpoint was used as the equivalent source. Table 8 offence rows per village were not checked.
- The api.usa.gov keyed API and the bulk "agencies" CSV on the CDE downloads page were not needed and not tested.
- The CDE agency list has no active/defunct flag; activity was inferred from employee reporting.

## 2. LEAIC, CSLLEA and LEAR: can they count village police departments?

### Takeaway
No count could be extracted: the ICPSR files need a login and the documentation pages refused automated access. The catalogue descriptions confirm the LEAIC carries FIPS place codes and Census government identifiers, which is what a village count would need.

### Cited Findings
- The LEAIC 2012 linkage variables "include the Originating Agency Identifier (ORI) code, Federal Information Processing Standards (FIPS) state, county and place codes, and Governments Integrated Directory government identifier codes" (search snippet of the catalogue record). — [ICPSR 35158](https://www.icpsr.umich.edu/web/NACJD/studies/35158)
- LEAIC 2012 records come from the Census of State and Local Law Enforcement Agencies (2008), the FBI's 2012 UCR offences file and an extract file (search snippet). — [ICPSR, About the LEAIC](https://www.icpsr.umich.edu/web/pages/NACJD/guides/leaic.html)
- A Law Enforcement Agency Roster (LEAR) 2016 exists as ICPSR 36697 (search result title only). — [ICPSR 36697](https://www.icpsr.umich.edu/web/ICPSR/studies/36697/staff)

### Inferences
- A place FIPS code on each agency would allow an exact join to `places-sf.parquet` (and so a village count free of name-matching), but the 2012 vintage is 14 years old; the FBI list used above is current.

### Gaps
- LEAIC codebook, CSLLEA 2018 and LEAR variable lists were not read (ICPSR returned HTTP 403); no published table by government type and state was found. Whether a later LEAIC edition than 2012 exists was not established.

## 3. State sources

### Takeaway
New York's DCJS personnel file gives the firmest state count: 212 village police departments reported personnel in 2025 and 226 in at least one of 2023-2025, all matching Census villages. Connecticut's 2018 resident-trooper list shows the towns containing Jewett City, Danielson, Litchfield and Bantam are policed by State Police troopers. No usable Michigan (MCOLES) or Vermont (Criminal Justice Council) directory was obtained.

### Cited Findings

New York (DCJS "Law Enforcement Personnel by Agency", 2007-2025, 9,113 rows; name pattern " Vg " or "Village PD", excluding "Town and Vg").

- 2025: 212 village departments (211 named "X Vg PD" plus "Muttontown Village PD"), every one with at least one sworn officer; 167 of the 211 have at least one full-time sworn officer. 212 of 532 = 39.8 percent. — [NY DCJS, Law Enforcement Personnel by Agency (data.ny.gov khn9-hhpq)](https://data.ny.gov/api/views/khn9-hhpq/rows.csv?accessType=DOWNLOAD)
- 2023-2025: 226 distinct village departments reported at least once (212 in 2025, 12 last in 2024, 2 last in 2023); all 226 match a Census village name. 226 of 532 = 42.5 percent. Departments missing from 2025 but present in 2024 include Highland Falls, Croton-on-Hudson and Walton, which are reporting gaps, not closures. — same source.
- The number of reporting village departments has been flat: 198 in 2007, 200 in 2012, 211 in 2019, 220 in 2022 and 2023, 217 in 2024, 212 in 2025; 233 distinct names across 2007-2025. — same source.
- 2025 also lists 6 joint "X Town and Vg PD" agencies (Webster, New Hartford, Camillus, Waterford, New Paltz, Macedon), plus "East Aurora-Town Of Aurora PD" and "Lakewood-Busti PD"; 115 town, 60 city and 53 sheriff agencies. — same source.

Connecticut.

- State list titled "Municipalities Participating in the Resident State Trooper Program as of July, 2018" (53 municipalities by my count of the table) includes "Griswold (Jewett City)" (Troop E, 1 trooper), "Killingly" (Troop D, 3 troopers; Danielson is in Killingly) and "Litchfield" (Troop L, 1 trooper; Litchfield and Bantam boroughs are in Litchfield). It does not list Old Saybrook, Newtown, Stonington, Milford or Groton, which have their own departments. — [CT OPM, Resident State Trooper list, July 2018](https://portal.ct.gov/-/media/opm/residentstatetrooperinfo72318pdf.pdf)
- A state document lists a "Killingly Resident State Trooper" office at 185 Broad Street, Danielson (search snippet). — [CT Office of Victim Advocate, Windham County police departments](https://portal.ct.gov/-/media/OVA/Services-by-County/WindhamCountyPoliceDepartmentspdf.pdf)
- Borough-by-borough result, combining the above with the FBI list: Bantam and Litchfield (Litchfield town, resident trooper); Danielson (Killingly, resident troopers); Jewett City (Griswold, resident trooper); Fenwick (Old Saybrook PD, per the earlier note); Newtown borough (Newtown town PD); Stonington borough (Stonington town PD); Woodmont (no agency; it lies in the City of Milford, which has "Milford Police Department" on the FBI list); Naugatuck (consolidated). — [FBI CDE agency list, CT](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/CT)

Vermont.

- The Vermont League of Cities and Towns counted 53 municipal police departments in June 2024 (from the earlier note), which equals the 53 municipal agencies on the FBI list. — [VLCT, A Snapshot of Municipal Policing in Vermont](https://www.vlct.org/sites/default/files/uploads/a-snapshot-of-municipal-policing-in-vermont-june-2024.pdf); [FBI CDE agency list, VT](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/VT)

Michigan.

- MCOLES published a "Michigan Law Enforcement Agencies" directory dated 16 August 2021 listing agencies alphabetically, and its current active-agency list sits in the login-only MITN system (search snippets). — [MCOLES LEA Directory, 2021](https://www.michigan.gov/documents/mcoles/LEA_Directory_Merge_Form_08162021_732690_7.pdf); [MCOLES directory page](https://www.michigan.gov/mcoles/information/directory)

### Inferences
- DCJS and the FBI agree closely for New York (212 to 226 versus 222 to 232), so about 40 to 44 percent of New York villages have their own department; about 31 percent (167 of 532) have one with any full-time sworn officer.
- For all eight separate Connecticut boroughs the police are the town's (or city's) department or State Police resident troopers. This confirms the earlier note and fills its gap on Danielson, Jewett City, Litchfield and Bantam, subject to the 2018 date of the trooper list.

### Gaps
- The MCOLES 2021 directory PDF was not parsed, so the Michigan count rests on the FBI list alone.
- No Vermont Criminal Justice Council or Department of Public Safety agency list was retrieved, and no Connecticut POST list of law enforcement units was found; the resident-trooper list is from 2018 and current participation was not confirmed.
- Whether Killingly and Griswold also employ town constables alongside troopers was not checked.

## 4. Vermont cases: who runs each department?

### Takeaway
Three Vermont villages run a police department: Bellows Falls, Swanton and Woodstock, and the last two sell coverage to their towns. Ludlow, Manchester, Morristown and Northfield are town departments, Lyndonville's passed to the Town of Lyndon in 2023, Johnson uses the county sheriff, and Enosburg Falls and Derby Line have no department.

### Cited Findings
- Woodstock: village-run. "The budget and policy decisions for the Police Department are the responsibility of the Village Trustees"; the Town of Woodstock "contracts annually with the Village of Woodstock for police services" under an inter-local contract, approved month-to-month in 2025; an FY27 Village-Town police contract was on a 22 June 2026 joint agenda (search summary of town documents). The Village Trustees handled the demotion of the police chief in 2025. — [Town of Woodstock joint packet, June 2026](https://www.townofwoodstock.org/fileadmin/files/Boards_and_Committees/Joint_Board/Meetings/2026/06/06.22.26Jointpacket.pdf); [Vermont Standard](https://thevermontstandard.com/amid-uncertainty-town-switches-to-month-to-month-policing-contract); [VTDigger, 12 May 2025](https://vtdigger.org/2025/05/12/woodstock-trustees-report-says-former-police-chief-failed-to-serve-as-town-role-model/)
- Swanton: village-run. The Swanton Village Police Department gives full-time service to the village and contracted part-time service to the town; "Swanton Village voters pay for a full-time (24/7) police department whereas Swanton Town voters only pay for a police contract for a certain number of hours" (search summary). — [Swanton Village Police Department](https://www.swantonvt.gov/services/police); [Swanton FAQ](https://www.swantonvt.gov/about/faq)
- Bellows Falls: village-run. The village charter authorises a village police department (earlier note), and the FBI assigns the department a population of 2,728 in 2025, the village's size, not the Town of Rockingham's. — [24 App. V.S.A. ch. 207 § 17](https://legislature.vermont.gov/statutes/section/24APPENDIX/207/00017); [FBI CDE](https://cde.ucr.cjis.gov/LATEST/pe/agency/VT0130100?from=2019&to=2025)
- Ludlow: town department. The Ludlow Selectboard reviews the police budget among "town department budgets" with the police chief (search summary); the FBI population is 2,163, the town's. The village charter's power to appoint up to five police officers is a historical provision. — [Vermont Journal](https://vermontjournal.com/politics/ludlow-discusses-town-budgets); [FBI CDE](https://cde.ucr.cjis.gov/LATEST/pe/agency/VT0140100?from=2019&to=2025); [24 App. V.S.A. ch. 235 § 32](https://legislature.vermont.gov/statutes/section/24appendix/235/00032)
- Manchester, Morristown, Northfield: FBI populations of 4,458, 6,269 and 5,916 in 2025 are town-sized, and the agency is named for the town in the Morristown case. — [FBI CDE, Manchester](https://cde.ucr.cjis.gov/LATEST/pe/agency/VT0020400?from=2019&to=2025); [Morristown](https://cde.ucr.cjis.gov/LATEST/pe/agency/VT0080100?from=2019&to=2025); [Northfield](https://cde.ucr.cjis.gov/LATEST/pe/agency/VT0120300?from=2019&to=2025)
- Lyndonville: the 2023 act made the Town of Lyndon "the surviving municipal corporation" from 1 July 2023 with village employees continuing; a local page says the Lyndonville Police Department's three full-time officers "patrol the entire town of Lyndon" (search summary, undated page). The FBI still lists "Lyndonville Police Department" with 4 officers and a population of 1,219 in 2025. — [24 App. V.S.A. ch. 126 § 1](https://legislature.vermont.gov/statutes/section/24APPENDIX/126/00001); [Lyndonville Fire](https://sites.google.com/view/lyndonville-fire-vt); [FBI CDE](https://cde.ucr.cjis.gov/LATEST/pe/agency/VT0030200?from=2019&to=2025)
- Johnson: no municipal department; the Town of Johnson contracts with the Lamoille County Sheriff's Department for patrol (search summary of selectboard packets). — [Town of Johnson selectboard packet, April 2022](https://townofjohnson.com/wp-content/uploads/2022/04/Selectboard-Packet-April-18th-2022.pdf)
- Enosburg Falls and Derby Line: no agency on the FBI list. Derby Line's charter provides for village police officers with constable-level powers (search summary), but no department is registered. — [FBI CDE agency list, VT](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/VT); [24 App. V.S.A. ch. 215 § 402](https://legislature.vermont.gov/statutes/section/24appendix/215/00402)

### Inferences
- 3 of 30 villages (10 percent) run a department. Two of the three (Swanton, Woodstock) police the whole town under contract and the FBI reports them at town population, so even in these cases the agency's practical footprint is the town.
- This settles the earlier note's open question on Woodstock (village) and Ludlow (town), and confirms its reading of Manchester, Morristown and Northfield.
- The Wikipedia entry for an Enosburgh department cited in the earlier note is not supported by the FBI list.

### Gaps
- Who polices Enosburg Falls and Derby Line day to day (sheriff contract or State Police) was not sourced; the Franklin County Sheriff's pages conflict on whether Enosburgh is a contract town.
- The Ludlow and Bellows Falls findings rest on indirect evidence (budget process, FBI population, charter); no municipal page stating the operator outright was retrieved. The VLCT table's separate "Town of Rockingham PD" has no FBI counterpart and was not explained.
- Lyndonville's post-merger legal status was not confirmed from a town source.

## 5. Connecticut: boroughs, City of Groton and Groton Long Point

### Takeaway
None of the eight separate boroughs runs a police department. The City of Groton and Groton Long Point each do, alongside the Town of Groton's department, so Groton has three municipal police agencies.

### Cited Findings
- City of Groton: "Groton Police Department", 28 officers, FBI population 10,378 in 2025. Town of Groton: "Groton Town Police Department", 63 officers, population 27,977. Groton Long Point: 6 officers, population 520. — [FBI CDE, Groton City](https://cde.ucr.cjis.gov/LATEST/pe/agency/CT0005900?from=2019&to=2025); [Groton Town](https://cde.ucr.cjis.gov/LATEST/pe/agency/CT00A5900?from=2019&to=2025); [Groton Long Point](https://cde.ucr.cjis.gov/LATEST/pe/agency/CT00B5900?from=2019&to=2025)
- Stonington Police Department is reported at 18,900 population (the town) with 40 officers; Newtown at 28,283 (the town) with 45; Naugatuck at 32,273 with 61; Old Saybrook (which covers Fenwick) at 10,745 with 23. — [FBI CDE agency list, CT](https://cde.ucr.cjis.gov/LATEST/agency/byStateAbbr/CT) and the employee endpoint for each ORI.
- Griswold (Jewett City), Killingly and Litchfield were resident-trooper towns in July 2018. — [CT OPM list](https://portal.ct.gov/-/media/opm/residentstatetrooperinfo72318pdf.pdf)

### Inferences
- The FBI's town population for Groton Town PD (27,977) is the town less the City of Groton and roughly Groton Long Point, so in FBI data the City of Groton is carved out of its town in the same way a New York village with a department is. That is evidence for treating the City of Groton (and arguably Groton Long Point) differently from the eight boroughs.

### Gaps
- Groton Long Point's legal form (the Census lists it as a borough) was not researched here.

## 6. How ICE data record arrest locality

### Takeaway
Nothing found says how ICE assigns a city or locality name to an arrest; the published arrest data describe location through state, a county field that is empty, a free-text "Apprehension Site Landmark" and ICE's own office geography (AOR and site), not through a defined city field.

### Cited Findings
- In the Deportation Data Project's ICE arrest releases, the former "Apprehension State" field is now "State", "Apprehension County" appears as "County" and is entirely empty, and "Apprehension Site Landmark" is carried unchanged (search summary of an analyst's review). — [Austin Kocher, A First Look at the Latest ICE Arrest Data](https://austinkocher.substack.com/p/a-first-look-at-the-latest-ice-arrest)
- The project added `apprehension_state_filled_in`, cutting missing state values from 15 percent to 0.5 percent, with the matching steps described in its codebook (search summary). — [Deportation Data Project release note](https://groups.google.com/a/law.berkeley.edu/g/deportation_data_updates/c/_ffb4_vnZFU)

### Inferences
- With no documented rule, locality in ICE records is whatever the officer or the landmark text supplies, so no source supports assuming it follows police jurisdiction rather than postal or common names.

### Gaps
- The Deportation Data Project codebook returned HTTP 403 and was not read; no ICE documentation on locality naming was found within the two searches allowed.
