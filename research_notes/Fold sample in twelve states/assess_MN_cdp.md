# Minnesota CDPs: fold or own cell (25 sampled)

## Pattern

The current rule holds for 19 of 25 rows. Verdicts: 12 own cell, 12 fold, 1 unclear.

Minnesota CDPs in this sample fall into three groups. Seven share their township's name (Dresbach, Goodland, Lake George, Lansing, Mahtowa, Marion, Stanchfield); folding them is right and costs nothing, because the cell keeps the name. Twelve are real named places: hamlets in a differently named township, usually with a current or former post office (Angle Inlet, Essig, Frontenac, Merrifield, Naytahwaush, Searles, Whipholt, Pickwick, Ebro, Ronneby) or in unorganized territory (Ball Club, Knife River); these should stay their own cells, because the township name is rarely a postal name and is often ambiguous (Twin Lakes, Cottonwood, Pine Lake). The remaining six rows are Census constructs (one of them, Rice Lake, unclear) with no postal identity and no usage found outside Census-derived pages; these are where the rule goes wrong.

## Disagreements with the current treatment

All five are currently "own cell" and I would fold them.

- **Fish Lake CDP** (75, Christiania township, Jackson County): lake-shore colony, formerly "Swastika Beach"; not a USPS name, mail says Windom; the name is shared with many Minnesota lakes.
- **Pine Bend CDP** (31, Island Lake township, Mahnomen County): no postal identity, mail via Lengby. From background knowledge (not looked up), "Pine Bend" in Minnesota usually means the refinery area in Dakota County, so free-text matches to this cell would mostly be wrong.
- **South End CDP** (34, La Prairie township, Clearwater County): generic directional name, described only as a CDP.
- **The Ranch CDP** (14, La Garde township, Mahnomen County): one small housing cluster, described only as a CDP.
- **The Lakes CDP** (590, Murray County): a collective Census name for shoreline housing around Lake Shetek, Lake Sarah and Lake Maria. Mail goes to Slayton, Tracy, Garvin or Currie. It spans four townships and the largest share is only 36% (Lake Sarah), so folding it whole into the plurality township would mislabel most residents; it should be split along township lines.

Unclear:

- **Rice Lake CDP** (274, La Prairie township, Clearwater County): large rural CDP near Lower Rice Lake, apparently a White Earth Reservation settlement and most of the township's population. I could not confirm that "Rice Lake" is used locally as a village name, it has no postal identity (mail says Bagley), and the name collides with other Rice Lakes in the state.

## Unorganized territory

- **Ball Club CDP** is in Bowstring Lake UT and **Knife River CDP** is in Lake No. 2 UT. Neither has a town government to fold into; the "town" is a Census statistical unit run by the county. Both should stay their own cells. Knife River has its own post office; Ball Club's mail says Deer River, but it is a recognised Leech Lake community.

## Surprises and data notes

- **Ronneby** was an incorporated city until it dissolved into Maywood township (2008 docket; Wikipedia-derived pages give 4 May 2009). Its input row is internally inconsistent: `usps_place_name` says "acceptable" while the `zips` column lists Ronneby as a name to avoid for 56329.
- **Knife River** was also once an incorporated village (1909) that reverted.
- **Marion**: a search summary claimed Marion township was annexed into Rochester in 2008. The township's own website shows it operating with about 4,066 residents, so that claim looks wrong.
- Several `usps_main_town_name` flags describe a different place of the same name, not the township: Twin Lakes (primary), Cottonwood (primary), Florence (acceptable), Pine Lake (avoid), and probably Rice Lake's "acceptable" on the place side. These flags should not be read as evidence that the township name is used for mail here.
- Ebro is the weakest "own cell": 50 people, post office closed 1975, and both Ebro and Falk are USPS names to avoid. Low confidence.

## What I could not check

- **Live USPS**: none confirmed. The USPS cities-by-ZIP page returned an empty form (results load by script). All postal evidence is from the precomputed mirror in the input file.
- **Follow-up searches**: the shared web-search budget ran out after one search per place. Second lookups for Rice Lake, Pine Bend, South End and The Ranch (whether they are named White Earth communities) could not be run; those four rest on one search plus the Wikipedia article each.
- Most local-usage evidence is Wikipedia text or search-result snippets, marked "(snippet)" in the CSV. Township websites were read only for Florence (Frontenac) and Marion; the Lansing township history page came back blank.
- No Google Maps, OpenStreetMap, real-estate or news-dateline checks were made, except one KAXE headline for Ball Club (snippet).
