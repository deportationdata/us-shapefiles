# Michigan CDPs: fold or own cell (25 sampled)

## Pattern

Verdicts: 14 fold, 10 own cell, 1 unclear. Eleven of the 25 disagree with the current treatment, and every disagreement runs the same way: a CDP that is currently its own cell should fold. The current rule (fold only when the CDP carries the township's name) gets the three same-name cases right (Allendale, Bath, Rockland) and gets the real post-office villages right (Amasa, Brimley, Comstock Park, Grand Marais, Henderson, Kincheloe, Temperance, Trufant, Wellston). It fails on the Michigan CDPs that are not villages at all: suburban tracts named after a school district (Forest Hills, Northview, Waverly), subdivision or compound names (Edgemont Park, Level Park-Oak Park, Millers Lake, Lakes of the North), and tiny hamlets whose mail goes to another town (Fulton, Hurontown, Loomis, Ruby).

The single best predictor in this sample is the postal name of the place's own ZIP codes. Every CDP whose name is the USPS primary name of a ZIP covering its residents came out as own cell (or as a same-name fold), and every CDP whose name is not primary for any of its own ZIPs came out as fold, with Pearl Beach (acceptable only) left unclear. The state-wide `usps_place_name` column is not a safe substitute: Fulton shows as "primary" only because of the other Fulton in Kalamazoo County.

## Disagreements with current treatment (all: currently own cell, should fold)

- **Edgemont Park** (Lansing charter township): 0.83 sq mi residential pocket, not a USPS name, addresses say Lansing.
- **Forest Hills** (Cascade charter township 50% / Ada township 50%): named after the school district; addresses say Ada or Grand Rapids. See the straddle note below.
- **Fulton** (Allouez township): former mine location beside Mohawk; addresses say Mohawk; name collides with Fulton in Kalamazoo County.
- **Hurontown** (Portage charter township): edge neighbourhood of Houghton; addresses say Houghton; not a USPS name.
- **Lakes of the North** (Mancelona township 57% / Star township 43%): private property owners' association; addresses say Elmira or Mancelona. Low confidence.
- **Level Park-Oak Park** (Bedford charter township, Calhoun County): Census compound of two subdivision names; addresses say Battle Creek.
- **Loomis** (Wise township): hamlet of 194, post office closed, addresses say Clare.
- **Millers Lake** (Deerfield township, Lapeer County): lake subdivision created in 2020 by splitting Barnes Lake-Millers Lake CDP; addresses say Columbiaville.
- **Northview** (Plainfield charter township): named after the school district; addresses say Grand Rapids.
- **Ruby** (Clyde township): crossroads whose post office closed in 1907; addresses say North Street. Low confidence.
- **Waverly** (Delta charter township): named after the school district; addresses say Lansing; the township is the recognised entity.

Unclear: **Pearl Beach** (Clay township). An old, real shoreline community holding over half the township's population, and an acceptable USPS name, but mail is addressed Algonac and "Clay" is equally acceptable. I could not check local usage.

## Surprising or worth knowing

- **Forest Hills straddle.** It is split 50/50 between Cascade and Ada and covers about 89% of Ada Township's land. Folding it into one plurality township would report half of it, and most of Ada, under the wrong township. It needs to dissolve into each township separately rather than fold to the plurality.
- **Lakes of the North** has the same problem on a smaller scale (57/43).
- **Folding does not always produce the name people use.** For Edgemont Park, Waverly, Northview, Level Park-Oak Park and Hurontown, residents' addresses name a neighbouring city (Lansing, Grand Rapids, Battle Creek, Houghton), not the township. Folding is still better than a cell under a name nobody writes, but strings like "Lansing, MI" will match the city cell.
- **Fulton name collision.** "Fulton, MI" in free text most likely means the Kalamazoo County community with the Fulton post office, not this Keweenaw CDP. Wikipedia also gives its 2020 population as 149 against 182 in the input.
- **Allendale.** The input puts 11% of the CDP's residents in Georgetown charter township and the CDP count (27,073) exceeds the township's (26,582); the Wikipedia article describes the CDP as wholly inside Allendale township. Does not change the verdict.
- **Kincheloe** matters for this use: it is the postal name for the former air base that now holds two state prisons and the county airport.
- **Oden** is own cell at low confidence: it has its own small post office (49764) but 80% of residents have Alanson addresses.
- Several search-result summaries noted that Wikipedia mirror pages (cavac.at, a Wikiwand mirror) contained embedded text addressed to AI tools. I did not open those pages or use them.

## What I could not check

- **No live USPS confirmations.** The USPS Cities-by-ZIP page loads results by script and returned only an empty form through WebFetch. All postal evidence is from the precomputed `zips` column.
- **Web search budget ran out** after one search per place. Follow-up searches for Pearl Beach, Oden, Temperance and Allendale did not run. For those I opened the Wikipedia articles directly instead (Pearl Beach, Allendale, Comstock Park, and the Clyde, Bedford, Littlefield and Allouez township articles).
- Most local-usage evidence is therefore from Wikipedia as summarised in search results, marked "(snippet)" in the CSV. I did not get to township websites (the Kinross township page returned 404), local news datelines, or map labels for any place.
- The Oden fish hatchery mention is from my own knowledge, not a source opened in this run.
