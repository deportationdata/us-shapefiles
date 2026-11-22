# Official sources for the USPS recommended (preferred) city name of each ZIP code

Research date: 2026-11-17 (downloads made 2026-11-18 ~06:45 UTC). Nothing was registered, no key requested, no terms accepted, the USPS lookup tool was not scripted. "Snippet only" marks a claim I could not read on the primary page.

Local downloads (scratchpad root `/private/tmp/claude-501/-Users-graeme--claude-spares-spare-nsjsKl/8d76e247-022c-4fc8-b950-c1098d762aeb/scratchpad/`):

| Local path (under scratchpad root) | URL | Bytes | sha256 |
|---|---|---|---|
| `usps_official/postalpro_zip_locale_detail/Zip_Locale_Detail.xlsx` | https://postalpro.usps.com/mnt/glusterfs/2026-10/Zip_Locale_Detail.xlsx (Last-Modified 2026-10-01) | 4,380,487 | 6e923786b70a5ab7ed93fd89cf0ffee3633c6daa58c86c6d4c8702dcd860bc07 |
| `usps_official/hud_zip_county_2021q4_legacy_url/ZIP_COUNTY_122021.xlsx` | https://www.huduser.gov/portal/datasets/usps/ZIP_COUNTY_122021.xlsx | 4,538,192 | e241fdaa6c39279a9a42f8fa91b2905ea0b848a65de5218f528791b0cf3cd68b |
| `usps_official/postalpro_ais_docs/AIS_Technical_Guide.pdf` | https://postalpro.usps.com/mnt/glusterfs/2022-05/AIS_Technical_Guide.pdf | 2,969,524 | 5dc2ae853d65534224d9fc4473d661d4877338ab792cee263bbb68ba1540dd3a |
| `usps_official/postalpro_ais_docs/AIS002.pdf` (AIS price list, July 2026) | https://postalpro.usps.com/mnt/glusterfs/2026-07/AIS002.pdf | 197,438 | 8696e608822e3df64d9f6a57f98099eb8d1ca16df2b22ede5c52dd042f329e6f |
| `usps_official/postalpro_ais_docs/LIC001_03.pdf` (AIS licence) | https://postalpro.usps.com/mnt/glusterfs/2026-07/LIC001_03.pdf | 376,245 | 16c3a28f2c16062551cc33917a7d858a9bfa6b4535a882751064c273d0ddba68 |
| `comparison_mirror/zip_code_database.csv` (third-party prototype file, for comparison only) | https://raw.githubusercontent.com/seanpianka/zipcodes/master/scripts/data/zip_code_database.csv | 4,652,237 | not recorded |

CSV extracts of the spreadsheets (made with a stdlib-only parser, `python3 -I`) are in `derived/` (`zld_sheet1.csv` = ZIP_Locale sheet, `zld_sheet2.csv` = "Unique" sheet, `zld_sheet3.csv` = "Other" sheet, `hud_sheet1.csv`); scripts are in `scripts/`.

Sanity-check ZIPs (my own lookups in the downloaded files):

| ZIP | Expected | ZIP Locale Detail 2026-10: LOCALE NAME [type] / PHYSICAL CITY (one line per row) | HUD 2021Q4 USPS_ZIP_PREF_CITY | Mirror primary_city (acceptable) |
|---|---|---|---|---|
| 05101 | Bellows Falls | BELLOWS FALLS [P] / BELLOWS FALLS | BELLOWS FALLS | Bellows Falls |
| 06239 | Danielson | DANIELSON [P] / DANIELSON | DANIELSON | Danielson (Killingly) |
| 08640 | Joint Base MDL | FORT DIX [B] / JOINT BASE MDL | JOINT BASE MDL | Joint Base Mdl (Fort Dix, Jb Mdl) |
| 08214 | Dennisville (PO box) | DENNISVILLE [P], class P / DENNISVILLE | DENNISVILLE | Dennisville |
| 15664 | Mammoth (PO box) | MAMMOTH [P], class P / MAMMOTH | MAMMOTH | Mammoth |
| 07920 | Basking Ridge | BASKING RIDGE [P] / BASKING RIDGE; VILLAGE [S] / BASKING RIDGE | BASKING RIDGE | Basking Ridge |
| 06037 | Berlin | BERLIN [B] / BERLIN; KENSINGTON [P] / BERLIN | BERLIN | Berlin (Kensington) |
| 02842 | Middletown | MIDDLETOWN [B] / MIDDLETOWN | MIDDLETOWN | Middletown |
| 04281 | South Paris | NORWAY [P] / NORWAY (physical ZIP 04268); SOUTH PARIS [P] / SOUTH PARIS | SOUTH PARIS | South Paris |
| 12946 | Lake Placid | LAKE PLACID [P] / LAKE PLACID | LAKE PLACID | Lake Placid |

## 1. USPS PostalPro free files (ZIP Locale Detail and relatives)

### Takeaway
PostalPro publishes exactly one free, no-login bulk ZIP file with names, `Zip_Locale_Detail.xlsx`, and it lists postal facilities (post offices, stations, branches) per ZIP, not the preferred last-line city. It is useful as an official list of active ZIPs and PO-box-class flags, but its LOCALE NAME equals the preferred city for only about three quarters of ZIPs, so it cannot carry the rule on its own.

### Cited Findings
- The page describes the file only as "The Excel spreadsheet lists ZIP Codes with the associated Area and District Codes"; dated "October 01, 2026", changelog "file updated 10/01/2026"; no column documentation, no stated frequency, no licence statement on the page. This one page is both the "ZIP Locale Detail" and the "ZIP Codes by Area and District codes" file; I found no separate free "ZIP Code Detail" or free Delivery Statistics file. — [PostalPro ZIP_Locale_Detail](https://postalpro.usps.com/ZIP_Locale_Detail)
- The stable URL is the page; the file URL is month-stamped (`/mnt/glusterfs/2026-10/Zip_Locale_Detail.xlsx`) and must be scraped from the page each run. Plain GET with a generic user agent returned HTTP 200, no login, no CAPTCHA. — [file](https://postalpro.usps.com/mnt/glusterfs/2026-10/Zip_Locale_Detail.xlsx)
- Columns in sheet `ZIP_Locale` (42,282 rows, 37,103 unique ZIPs; 5,009 ZIPs have more than one row): AREA NAME, DISTRICT NAME, DISTRICT NO, DELIVERY ZIPCODE, ZIP CLASS CODE (blank 33,637 / P 8,645), LOCALE NAME, LOCALE KEY, LOCALE TYPE (P 32,382; S 4,913; 4 2,262; B 2,081; C 267; others), PHYSICAL DELV ADDR, PHYSICAL CITY, PHYSICAL STATE, PHYSICAL ZIP, PHYSICAL ZIP 4, FDB KEY, DROP SITE, FINANCE NO. Sheet `Unique` (2,232 ZIPs, mostly class U) and sheet `Other` (2,404 rows; classes blank/P/M) have the same columns through PHYSICAL ZIP 4. All sheets together: 41,486 distinct ZIPs. Fields are space-padded. — my inspection of the [file](https://postalpro.usps.com/mnt/glusterfs/2026-10/Zip_Locale_Detail.xlsx)
- LOCALE NAME is a facility name, not the preferred last line: 07920 has rows BASKING RIDGE (type P) and VILLAGE (type S, a station); 04281 has NORWAY and SOUTH PARIS; 06037 has BERLIN (B) and KENSINGTON (P); 08640 has LOCALE NAME "FORT DIX" while PHYSICAL CITY is "JOINT BASE MDL" (the preferred name). — my inspection of the [file](https://postalpro.usps.com/mnt/glusterfs/2026-10/Zip_Locale_Detail.xlsx)
- Measured against HUD's USPS_ZIP_PREF_CITY (2021Q4; 39,462 ZIPs in both files): some LOCALE NAME equals the preferred city for 74.4% of ZIPs; the only LOCALE NAME equals it for 63.7%; some PHYSICAL CITY equals it for 91.5%. — my comparison of the [PostalPro file](https://postalpro.usps.com/mnt/glusterfs/2026-10/Zip_Locale_Detail.xlsx) and the [HUD file](https://www.huduser.gov/portal/datasets/usps/ZIP_COUNTY_122021.xlsx)
- The City State layout distinguishes a name's facility type from its mailing status: facility codes "B = Branch, C = Community post office (CPO), N = Non-postal community name, former USPS facility, or place name, P = Post Office, S = Station, U = Urbanization", and a separate "Preferred Last Line City State Name". The same letters appear as LOCALE TYPE in ZIP Locale Detail. — [AIS Products Technical Guide](https://postalpro.usps.com/mnt/glusterfs/2022-05/AIS_Technical_Guide.pdf)
- Reuse: USPS site terms say "Material on this site is the copyrighted property of the United States Postal Service... may not under any circumstances be reproduced or used without prior written permission. Users may view and download material from this site only for... (a) for personal, non-commercial home use; (b) where the materials clearly state that these materials may be copied...; or (c) with the express written permission of the Postal Service." — [USPS Terms of use](https://about.usps.com/who/legal/terms-of-use.htm)
- The seanpianka/zipcodes README labels ZIP Locale Detail "Public domain"; the PostalPro page itself makes no such statement. — [zipcodes README](https://github.com/seanpianka/zipcodes); contradicted in spirit by [USPS Terms of use](https://about.usps.com/who/legal/terms-of-use.htm)

### Inferences
- LOCALE TYPE codes P/S/B/C match the City State facility codes, so LOCALE NAME = name of a postal facility serving the ZIP; "4/5/6/Z/E/F/K" are other facility kinds (undocumented).
- A rule "LOCALE NAME of the type-P row" would wrongly make Norway the name of 04281 and Kensington the name of 06037, and would miss place-name preferred cities (08691 Robbinsville is a "Place Name", not a post office, per the 2020 Postal Bulletin).
- Whether the general usps.com terms govern postalpro.usps.com downloads is not stated on PostalPro; a cautious build would download at build time and publish only derived flags, not redistribute the spreadsheet.

### Gaps
- No USPS column dictionary for ZIP Locale Detail was found; meanings of LOCALE TYPE 4/5/6/Z/E/F/K, DROP SITE and FDB KEY are undocumented.
- Update cadence is not stated (observed: file stamped the 1st of the month; the mirror's README assumes monthly).
- PostalPro's site search returned 404 to a plain GET, so I could not exhaustively rule out other free ZIP files; none is linked from the pages read.

## 2. USPS City State Product (AIS)

### Takeaway
This is the authoritative source: every ZIP's names with a mailing-name flag and the preferred last-line name, plus a PO-Box-only record type. It is paid ($730/year list price, July 2026), needs an EPF account and a signed licence, and the licence forbids distributing the product; it is the only official source that carries acceptable and not-acceptable names.

### Cited Findings
- "City State Product is a comprehensive list of ZIP Codes with corresponding city and county names. This file also contains other names by which a Post Office may be known." Delivered through Electronic Product Fulfillment (EPF) after an EPF Web Access Request Form and AIS order form; "Updates are issued monthly". — [PostalPro City State Product](https://postalpro.usps.com/address-quality/city-state-product)
- Detail record fields: ZIP Code; City State Key; ZIP Classification Code ("Blank = Non-Unique, M = APO/FPO/DPO Military, P = PO Box Zip, U = Unique Zip"); City State Name; 13-char abbreviation; City State Name Facility Code; City State Mailing Name Indicator ("Y = Mailing Name, N = Non-Mailing Name"); Preferred Last Line City State Key; Preferred Last Line City State Name; City Delivery Indicator; Unique ZIP Name Indicator; Finance Number; State; County Number; County Name. — [AIS Technical Guide, p. 15-16](https://postalpro.usps.com/mnt/glusterfs/2022-05/AIS_Technical_Guide.pdf)
- Definitions: Mailing Name Indicator "Y = City/state name is a USPS-approved mailing name. N = City/state name is not approved for mailing purposes."; Preferred Last Line City State Name "contains the default preferred or alternate preferred last-line name for a ZIP Code"; City State Name "May be the name of a city, USPS entity (such as a Post Office or station), community, USPS-preferred last line, municipality, or urbanization (Puerto Rico only)." — [AIS Technical Guide, data element definitions](https://postalpro.usps.com/mnt/glusterfs/2022-05/AIS_Technical_Guide.pdf)
- A separate "P.O. Box Only" record type lists "P.O. Box Only Delivery Zones... communities where the customer's only acceptable form of postal delivery is through a P.O Box address. This flag is different from the existing ZIP Classification code 'P'... which indicates where a ZIP Code only has P.O. Boxes but other forms of postal delivery are also provided to the community." — [AIS Technical Guide, p. 2-3](https://postalpro.usps.com/mnt/glusterfs/2022-05/AIS_Technical_Guide.pdf)
- Price: City State (item 103100) $730.00 base price; "City State Product is provided at no additional charge when Carrier Route, ZIP + 4, Five-Digit ZIP, or eLOT products are ordered. Products purchased one time only cost 90% of Base Price." — [AIS Products Pricing, July 2026](https://postalpro.usps.com/mnt/glusterfs/2026-07/AIS002.pdf)
- Licence: use is "FOR YOUR INTERNAL CORPORATE OR PERSONAL USE on one computer at one location"; "Unauthorized copying of the PRODUCT, including PRODUCT that has been modified, merged or included with other software and/or data... is expressly forbidden"; "nor may you distribute copies of the PRODUCT"; "PRODUCT versions that are more than 105 DAYS OLD are NOT authorized for use"; "This license is effective for one year from date of purchase". A paid "LICENSE AMENDMENT" authorises "ADDITIONAL COPIES of PRODUCT, in whole or in part, which may or may not contain value added information". — [AIS Copyright/License Agreement](https://postalpro.usps.com/mnt/glusterfs/2026-07/LIC001_03.pdf)
- Publication 28 ties recommended names to this file: "It is strongly recommended that addresses use only approved Last Line (city) names as described in the Postal Service City State file currently in effect. City names with the City State Mailing Name indicator flag set to YES... are considered part of a complete and standardized address; city names with the flag set to NO... should not be used". — [Pub 28 section 221](https://pe.usps.com/text/pub28/28c2_006.htm)

### Inferences
- "Preferred" (default) = Preferred Last Line City State Name; "acceptable" = other names with Mailing Name Indicator Y; "not acceptable" = names with indicator N. This maps one-to-one onto the mirror's primary_city / acceptable_cities / unacceptable_cities columns.
- The licence text does not address publishing a derived yes/no flag per census place. Publishing the name list itself would be distribution "in part"; a derived boolean is a grey area that only USPS (licence amendment or written permission) can settle.
- The 105-day rule means an unattended build would need a fresh monthly/quarterly pull under a current subscription.

### Gaps
- Not downloaded (needs account, payment, licence acceptance). The EPF access form and order form were not opened.
- Whether USPS grants written permission or a FOIA release for the City State file to open-data projects: no source found.

## 3. USPS APIs (developers.usps.com Addresses v3 city-state; retired Web Tools)

### Takeaway
The API is official but unusable here: it returns only one city per ZIP, defaults to 60 calls per hour, and its terms expressly forbid data mining, building a database for third parties, and any use not tied to mailing or shipping.

### Cited Findings
- `GET https://apis.usps.com/addresses/v3/city-state?ZIPCode=NNNNN`: "Returns the city and state corresponding to the given ZIP Code"; response schema is a single CityAndState object (city, state, ZIPCode); no acceptable or not-acceptable names; OAuth2 bearer token; a 429 response is defined. — [Addresses API spec v3.3.1](https://developers.usps.com/sites/default/files/apidoc_specs/addresses-v3r2_5.yaml)
- Default product APIs (incl. Addresses) come "each with a quota of 60 calls per hour"; a quota increase needs a request form. — [USPS developer portal, getting started](https://devs.usps.com/node/47) (read via fetch summary)
- "All USPS APIs utilize OAuth"; consumer key and secret are created by adding an app in the developer portal; over-quota users must submit a service request. — [USPS API FAQ](https://developers.usps.com/faq)
- Terms: "User agrees to only use the USPS Web site, APIs, and USPS data to facilitate USPS shipping or mailing transactions unless specifically allowed otherwise in a specific USPS license." You will not "use the Services for datamining or datascraping purposes; use the Services or data for the purpose of creating an address list; use the Services or data to create a database with the data from the Services for third-party usage; ... use the Services to develop a database, infobase, artificial intelligence model, or similar database service... for sale to, distribution to, display to, or use by others; ... copy, store, edit, change, prepare any derivative work of... any of the information or data provided through the Services or usps.com except for uses related to Your mailing, shipping, and purchase of USPS products and services". — [USPS API Terms and Conditions](https://developers.usps.com/terms-and-conditions)
- Legacy Web Tools (incl. CityStateLookup) were retired 25 January 2026. — snippet only, vendor blogs ([Smarty](https://www.smarty.com/blog/usps-api-rate-limit), [revaddress](https://revaddress.pages.dev/blog/usps-web-tools-shutdown-2026/)); not confirmed on a USPS page.

### Inferences
- At 60 calls/hour, ~41,500 ZIPs would take about 29 days per refresh, and the purpose (a public dataset) is outside the terms regardless of speed.

### Gaps
- No USPS page read confirming the Web Tools retirement date.

## 4. USPS "Cities by ZIP Code" lookup tool (tools.usps.com)

### Takeaway
It shows the recommended city plus "other city names recognized" and "city names to avoid" for a ZIP, but it is an interactive tool covered by the same no-scraping terms; not a build input.

### Cited Findings
- HUD points users to this tool for names: "Recommended City Names can be searched on the USPS ZIP Code Lookup page." — [HUD crosswalk FAQ](https://www.huduser.gov/portal/datasets/usps_crosswalk.html), linking to [tools.usps.com citybyzipcode](https://tools.usps.com/zip-code-lookup.htm?citybyzipcode)
- The API terms extend to usps.com: no "datamining or datascraping", and no copying or storing of "data provided through the Services or usps.com except for uses related to Your mailing, shipping". — [USPS API Terms and Conditions](https://developers.usps.com/terms-and-conditions)
- General site terms require written permission to "reproduce, republish, upload, post, transmit, distribute or publicly display material from this Web site". — [USPS Terms of use](https://about.usps.com/who/legal/terms-of-use.htm)
- The mirror's upstream also blocks automation: "Its bot protection prevents automated downloads" (said of unitedstateszipcodes.org, not USPS). — [zipcodes README](https://github.com/seanpianka/zipcodes)

### Gaps
- I did not load the tool (per instructions), so the three-category display and its bot detection are from prior knowledge and the task brief, not verified today. `tools.usps.com/robots.txt` returned the USPS 404 page.

## 5. HUD-USPS ZIP Code Crosswalk files

### Takeaway
HUD is the best government-guaranteed source of the preferred name: USPS_ZIP_PREF_CITY is supplied to HUD by USPS under their data agreement, quarterly, since 2021 Q1. It gives the preferred name only (no acceptable names); current files need a free HUD User login or API token. In the one file obtainable without login (2021 Q4) all ten test ZIPs, including the two PO-box ZIPs, are present and correct.

### Cited Findings
- Field definitions: "USPS_ZIP_PREF_CITY USPS preferred city name. Note: ZIP code preferred names frequently do not align with administrative/political names..." and "USPS_ZIP_PREF_STATE USPS preferred state address state". — [HUD USPS ZIP Code Crosswalk Files](https://www.huduser.gov/portal/datasets/usps_crosswalk.html)
- Provenance: "Since 2005, [HUD] has worked in partnership with the United States Postal Service (USPS) to receive administrative data on address vacancies... In the most recent agreement between HUD and USPS, new fields have become available regarding (1) the USPS preferred name and preferred state for a ZIP Code". "Beginning in 2021 Q1, data acquired by HUD from USPS will have the USPS Preferred City Name, which is not the only recognized name but the name USPS primarily recognizes. USPS also keeps records of names to avoid; however, only USPS preferred name is provided, not the other recognized names or the names to avoid." — [Din, "New Data Fields for HUD Aggregated USPS Administrative Data on Address Vacancies", Cityscape 23(3), 2021](https://www.huduser.gov/portal/sites/default/files/periodicals/cityscpe/vol23num3/ch11.pdf) (author's views, not official HUD policy, per its disclaimer)
- Files "are derived from data in the quarterly USPS Vacancy Data. They originate directly from the USPS; are updated quarterly"; "We try to publish the Crosswalk Files by the end of the month following the quarter." — [HUD crosswalk page](https://www.huduser.gov/portal/datasets/usps_crosswalk.html)
- PO boxes, per documentation: "ZIP codes that only serve PO Boxes will not appear in the files"; FAQ "Are PO Box only ZIP Codes available in the Crosswalk Files? No." Also "less than 1% of the total number of active 5-digit ZIP codes" are excluded for geocoding failures. — [HUD crosswalk page](https://www.huduser.gov/portal/datasets/usps_crosswalk.html)
- PO boxes, as observed: the 2021 Q4 ZIP-COUNTY file has 39,488 unique ZIPs, each with exactly one preferred city, and includes 08214 DENNISVILLE and 15664 MAMMOTH; it contains 8,413 of the 9,179 ZIPs the mirror types as "PO BOX" (92%), 29,741 of 29,803 "STANDARD", 1,333 of 2,080 "UNIQUE", 0 military. Columns: zip, county, usps_zip_pref_city, usps_zip_pref_state, res_ratio, bus_ratio, oth_ratio, tot_ratio. — my inspection of [ZIP_COUNTY_122021.xlsx](https://www.huduser.gov/portal/datasets/usps/ZIP_COUNTY_122021.xlsx); in tension with the documentation quoted above
- Internal contradiction on the HUD page: the FAQ still says "Are names for ZIP codes available? No. Unfortunately, the underlying data used to create the Crosswalk Files does not contain USPS Recommended City Names", while the data dictionary on the same page and the files carry USPS_ZIP_PREF_CITY. — [HUD crosswalk page](https://www.huduser.gov/portal/datasets/usps_crosswalk.html)
- Access: "The HUD-USPS ZIP Code Crosswalk Files remain available to all users. To access the data, please login here." Legacy direct URLs return 200 for 2021 Q4 but 404 for every quarter from 2022 Q1 to 2026 Q3 that I probed. — [HUD crosswalk page](https://www.huduser.gov/portal/datasets/usps_crosswalk.html)
- API: `https://www.huduser.gov/hudapi/public/usps?type=N&query=All` with `Authorization: Bearer <token>`; `query=All` or a state returns everything for a type and quarter (`year`, `quarter` optional); response includes "city string (Available 1st Quarter 2021 onwards for all types)" and "state"; token requires an account ("Sign up for an account... Create New Token"); an unauthenticated call returned 401. "Terms of Use: No special restrictions or limitations on using the item's content have been provided." — [HUD USPS Crosswalk API](https://www.huduser.gov/portal/dataset/uspszip-api.html)

### Inferences
- One API call per quarter (`type=2&query=All`, ZIP-County) with a token stored as a CI secret gives an unattended, reproducible pull of ZIP to preferred city; the result can be cached in the repository since HUD states no restrictions.
- HUD's "PO Box only" exclusion seems to bite only for ZIPs with no geocodable address record at all; most ZIPs that vendors label "PO BOX" were present in 2021 Q4. Coverage in 2026 files is untested and should be re-measured after the owner obtains a token: about 766 PO-box-type and 747 unique-type ZIPs in the mirror were absent from HUD 2021 Q4.
- HUD's name is the default preferred last line, so the rule would lose acceptable names such as Kensington (06037) and Fort Dix (08640) unless a second source supplies them.

### Gaps
- Current-quarter file not downloaded (needs login). The HUD API Terms of Service link was not opened.
- No HUD statement of which USPS system (AMS / City State) feeds the field.

## 6. Other federal sources

### Takeaway
No other federal bulk product was found that carries the USPS preferred city for every ZIP. Census ZCTAs carry no names; the National Address Database has a postal-community field per address point, but it is filled by state and local contributors and coverage is partial.

### Cited Findings
- ZCTAs "are generalized areal representations of the geographic extent and distribution of the point-based ZIP Codes built using 2020 Census tabulation blocks"; for ZIP questions Census says "Please contact the US Postal Service for additional information about ZIP codes." The page describes no city-name attribute. — [Census ZCTA page](https://www.census.gov/programs-surveys/geography/guidance/geo-areas/zctas.html)
- NAD schema field `Post_Comm` ("Postal Community Name", text 40): a city name for the address's ZIP code from the USPS City State file. — snippet only, [NAD schema v1](https://www.transportation.gov/sites/dot.gov/files/docs/mission/gis/national-address-database/308816/nad-schema-v1.pdf) (transportation.gov returned 403 to direct fetches)
- A 2020 FGDC address-subcommittee recommendation defines Postal City Name as the preferred city name for the ZIP "as prescribed by the USPS City-State file and indicated on USPS.com". — snippet only, [FGDC NAD content recommendation](https://www.fgdc.gov/organization/working-groups-subcommittees/address-sc/meetings/sep-2020/nad-content-recommendation-place-geography-sep.pdf)

### Inferences
- NAD could at best corroborate; names are typed by local address authorities, so it is not "guaranteed USPS-derived" and has state-level holes.
- TIGER address ranges and the Census Geocoder carry ZIP codes but no postal city field (prior knowledge, not re-verified today).

### Gaps
- Not checked: data.gov "USPS ZIP codes" listings, USPS ArcGIS/open-data pages, FCC, IRS SOI and CMS ZIP files. I know of none carrying an authoritative preferred city, but this is unverified.

## 7. Provenance of the prototype mirror (seanpianka/zipcodes)

### Takeaway
The mirror's file is a manually refreshed copy of the unitedstateszipcodes.org free database; nothing in the chain documents a USPS licence, so it does not meet "guaranteed from USPS". Empirically, though, its primary_city matched HUD's USPS preferred city for every one of 39,487 shared ZIPs.

### Cited Findings
- README: the dataset is assembled from "unitedstateszipcodes.org — the rich base data (city aliases, zip type, area codes, county, timezone), committed in-repo as `scripts/data/zip_code_database.csv`. Its bot protection prevents automated downloads, so this file is refreshed manually on occasion"; plus GeoNames (CC BY 4.0) and USPS ZIP Locale Detail "used to add zipcodes missing from the base CSV". Repository licence: MIT. — [zipcodes README](https://github.com/seanpianka/zipcodes)
- The file now lives at `scripts/data/zip_code_database.csv` (the repository-root path returns 404). Columns: zip, type, decommissioned, primary_city, acceptable_cities, unacceptable_cities, state, county, timezone, area_codes, world_region, country, latitude, longitude, irs_estimated_population; 42,735 rows (30,003 STANDARD, 9,396 PO BOX, 2,545 UNIQUE, 791 MILITARY; 1,040 decommissioned). — [raw file](https://raw.githubusercontent.com/seanpianka/zipcodes/master/scripts/data/zip_code_database.csv)
- Agreement test: for all active mirror ZIPs present in HUD 2021 Q4 (29,741 standard, 8,413 PO box, 1,333 unique), upper-cased primary_city equals USPS_ZIP_PREF_CITY in 100% of cases; zero disagreements. — my comparison with [HUD ZIP_COUNTY_122021.xlsx](https://www.huduser.gov/portal/datasets/usps/ZIP_COUNTY_122021.xlsx)

### Inferences
- The MIT licence covers the repository's code; it cannot grant rights in a third-party site's database that the maintainer copied by hand.
- The 100% match shows the mirror's primary_city is the USPS preferred last line (as of roughly the same vintage), so switching the preferred-name test to HUD should reproduce the prototype's results wherever only primary_city was used.

### Gaps
- unitedstateszipcodes.org returned HTTP 403 (bot protection), so its own source statement and licence terms could not be read or quoted.
- The mirror's refresh date is unknown; a perfect match with a 2021 file may mean the mirror is stale relative to 2026.

## 8. How preferred names are assigned and how stable they are

### Takeaway
The preferred last line is normally the delivering post office's name, but USPS can set it to a place name on municipal request. Changes are individual announcements in the Postal Bulletin; USPS publishes no change rate, but its policy stresses stability.

### Cited Findings
- USPS can "allow the alternate use of more than one city name in the last line of an address, while retaining the use of the ZIP Code of the Post Office providing delivery"; the Boundary Review Process exists "to consider municipal requests to modify authorized last lines of address and/or ZIP Code boundaries to provide municipal identity"; after a boundary accommodation, further requests "will not be considered more frequently than once every 10 years"; requests go in writing to the district manager, with appeal to headquarters. — [USPS Postal 101: ZIP Code Boundaries](https://about.usps.com/who/government-relations/assets/postal-101-zip-codes.pdf)
- Examples of changes: "This announcement changes the Preferred Last Line of this ZIP Code from Trenton, NJ to Robbinsville, NJ. Use Robbinsville, NJ 08691" (new entry typed "Place Name", effective 05/09/2020) and "from Waite Park, MN to Saint Cloud, MN" for 56388. — [Postal Bulletin 22550, 2020](https://about.usps.com/postal-bulletin/2020/pb22550/html/info_001.htm)
- The policy document is the 2016 USPS "Management Instruction: ZIP Code Boundary Review Process". — [CRS IF12132, Postal Primer: ZIP Codes and Boundary Review Process](https://www.everycrsreport.com/reports/IF12132.html)
- "USPS recognizes multiple names for a ZIP Code but also recommends that some names should not be used." — [Din 2021, Cityscape](https://www.huduser.gov/portal/sites/default/files/periodicals/cityscpe/vol23num3/ch11.pdf)

### Inferences
- A handful of preferred-name changes per Postal Bulletin issue suggests tens per year out of ~41,000 ZIPs; a quarterly HUD refresh is ample. This is an estimate from one bulletin, not a published rate.

### Gaps
- No USPS statistic on the annual number of preferred-last-line changes was found.
- The 2016 Management Instruction itself was not located.

## 9. Coverage of PO-box ZIPs and acceptable names; recommendation

### Takeaway
Only the paid City State Product officially covers everything (all ZIP classes, preferred, acceptable and not-acceptable names). Among free, government-guaranteed sources, HUD gives preferred names for delivery ZIPs and, in practice, most PO-box ZIPs; ZIP Locale Detail gives an official ZIP roster with PO-box class and facility names. Recommended: HUD API as the preferred-name source, ZIP Locale Detail as a supplement, the mirror kept only as a cross-check.

### Cited Findings
| Source | From USPS? | Preferred name | Acceptable names | PO-box ZIPs | Bulk, unattended | Account / cost | Reuse terms |
|---|---|---|---|---|---|---|---|
| City State Product | USPS itself | yes | yes (flag Y/N) | yes (class P + PO Box Only records) | yes, monthly via EPF | EPF account, $730/yr | internal use, no distribution, 105-day expiry |
| HUD crosswalk | USPS data via HUD agreement | yes | no | documented no; observed 92% of PO-box-type ZIPs in 2021 Q4 | yes, one API call per quarter | free HUD User account + token | "No special restrictions" |
| ZIP Locale Detail | USPS itself | no (facility names; 74% coincide) | partly, as facility names | yes (ZIP CLASS CODE P: 8,645 rows) | yes, plain GET, monthly | none | no statement; general USPS terms restrictive |
| USPS Addresses API | USPS itself | yes, one city | no | presumably | no (60/hour; mining prohibited) | USPS account + OAuth app | database building prohibited |
| USPS lookup web tool | USPS itself | yes | yes | yes | no | none | scraping prohibited |
| Census ZCTA | no | no | no | no | yes | none | public |
| NAD Post_Comm | local authorities | partial | no | no | yes | none | public |
| seanpianka mirror | undocumented third party | yes (100% = HUD 2021 Q4) | yes | yes | yes (git) | none | unclear upstream rights |

Sources for the table rows: [City State page](https://postalpro.usps.com/address-quality/city-state-product), [AIS pricing](https://postalpro.usps.com/mnt/glusterfs/2026-07/AIS002.pdf), [AIS licence](https://postalpro.usps.com/mnt/glusterfs/2026-07/LIC001_03.pdf), [HUD page](https://www.huduser.gov/portal/datasets/usps_crosswalk.html), [HUD API](https://www.huduser.gov/portal/dataset/uspszip-api.html), [ZIP Locale Detail](https://postalpro.usps.com/ZIP_Locale_Detail), [USPS API terms](https://developers.usps.com/terms-and-conditions), [Census ZCTA](https://www.census.gov/programs-surveys/geography/guidance/geo-areas/zctas.html), [zipcodes README](https://github.com/seanpianka/zipcodes).

### Inferences
- Recommendation: (1) primary = HUD USPS_ZIP_PREF_CITY via the HUD API (owner registers and stores the token as a build secret; cache each quarter's ZIP to city table in the repo for reproducibility). (2) Supplement = ZIP Locale Detail for ZIPs HUD omits: for a ZIP with a single row whose PHYSICAL ZIP equals the ZIP, the LOCALE NAME / PHYSICAL CITY is a defensible official name (e.g. a village with only a PO-box post office), but multi-row ZIPs must not be resolved from it. (3) If acceptable names matter to the rule, the only compliant official route is a City State subscription plus written USPS permission to publish derived flags; otherwise drop acceptable names, or treat ZIP Locale Detail type-P/C facility names as an official but narrower stand-in (it does list Kensington for 06037 and Fort Dix for 08640, but also Norway for 04281).
- The prototype's results that used only primary_city should be reproducible from HUD; results that relied on acceptable_cities cannot be reproduced from any free official source.

### Gaps
- HUD's 2026 coverage of PO-box ZIPs is untested; needs a token.
- Whether USPS would permit publishing a per-place boolean derived from the City State file is unanswered; it requires asking USPS (AIS customer care, 1-800-238-3150, per the licence).
- I did not test how many census places in the twelve states change status under HUD-only versus mirror names.
