
import requests, json, time, re, pandas as pd
from bs4 import BeautifulSoup

# https://sumodb.sumogames.de/Default.aspx
# https://en.wikipedia.org/wiki/Glossary_of_sumo_terms

# Basho = Tournament
# Banzuke = Overall tournament results
# Torikumi = A tournament bout/match

# Bashos occur every odd month and are 15 days long (+ playoffs, which are coded as day 16)
# Torikumi (i.e. daily) records begin 1909 Natsu. Banzuke (i.e. overall) records begin 1757 Fuyu

# Define our sumo database as an empty dictionary keys for what we want to web-scrape
sumo_database = {"years_months": [], "days": [], "basho_names": [], "matches": {}, "results": {}, "banzuke": {}}


# Define our generice webscraping function
def web_scrape(url):
    global soup
    r = requests.get(url)
    # If Error 404
    error_count = 0
    while not r.ok:
        error_count += 1
        print(f"Error 404: {error_count} attempts", end="\r")
        r = requests.get(url)

    print("URL accepted")
    soup = BeautifulSoup(r.text, features="html.parser")


# We are going to collect a list of all the available Bashos from the website
url = "https://sumodb.sumogames.de/Banzuke.aspx"
web_scrape(url)

# For all the Bashos in the dropdown list, get the name and value
for i in soup.find(class_="bashoselect").find_all("option"):
    sumo_database["years_months"] += [i["value"]]
    sumo_database["basho_names"] += [i.text]

# Now we need the number of days. Some have 10 or less, others have 15, and Playoffs are included on a separate day page
# Iterating over all of the Banzuke webpages, extract from the daytable how many days that tournament had
start_time = time.time()
for year_month in sumo_database["years_months"]:

    print(year_month)

    url = f"https://sumodb.sumogames.de/Banzuke.aspx?b={year_month}"
    web_scrape(url)

    # If no days, add as None
    # Do not omit, as we need same length with years_months (to properly filter out and index later)
    if soup.find(class_="daytable") is None:
        sumo_database["days"].append(None)
    else:
        data = []
        # Find the table in our html
        table = soup.find("table", attrs={"class": "daytable"})
        # Get our rows
        rows = table.find_all("tr")

        for row in rows:
            # Over the rows find the values of our columnes
            cols = row.find_all("td")
            # Convert to text and add to data
            data += [x.text for x in cols]

        sumo_database["days"] += [["16" if x == "Playoffs" else x for x in data]]
# sumo_database["days"] += [["".join(re.findall("d=(\d+)$", i["href"])) for i in soup.find(class_="daytable").find_all("a") if "Results" in i["href"]]]

end_time = time.time()
print(str(round((end_time - start_time)/60, 1)) + " mins elapsed")
# 13.5 mins elapsed

# Check the length of years_months = length of days
print(len(sumo_database["years_months"]) == len(sumo_database["days"]) == len(sumo_database["basho_names"]))

# Results are stored in the table as images. These are the mappings
# hoshi_shiro = WIN (white circle)
# hoshi_kuro = LOSS (black circle)
# hoshi_hikiwake = DRAW (white triangle)
# hoshi_fusensho = Retirement/Absence WIN (white square)
# hoshi_fusenpai = Retirement/Absence LOSS (black square)
# hoshi yasumi = Out of basho (dash)

# We will need to replace these image names with their actual meaning. Create a replacement dictionary
rep_dict = {"img/": "", ".gif": "",
            "hoshi_shiro": "WIN 1",
            "hoshi_kuro": "LOSS 0",
            "hoshi_fusensho": "WIN_ABSENCE 1",
            "hoshi_fusenpai": "LOSS_ABSENCE 0",
            "hoshi_hikiwake": "DRAW 0"}


# I don't want to chain .replace().replace().replace()... Use a function for this
def multiple_replace(string, rep_dict):
    pattern = re.compile("|".join([re.escape(k) for k in sorted(rep_dict, key=len, reverse=True)]), flags=re.DOTALL)
    return pattern.sub(lambda x: rep_dict[x.group(0)], string)


# Iterate over years_months and days to extract the table of matches and results
start_time = time.time()
for i in range(len(sumo_database["years_months"])):

    year_month = sumo_database["years_months"][i]

    # If there are no days, then there wasn't a tournament. Add this as None
    if sumo_database["days"][i] is None:
        sumo_database["matches"][year_month] = None
        sumo_database["results"][year_month] = None
    # Otherwise, iterating over the days...
    else:
        for day in sumo_database["days"][i]:

            print(year_month + '_' + str(day))
            # Key for naming
            key = year_month + "_" + str(day).rjust(2, "0")

            url = f"https://sumodb.sumogames.de/Results.aspx?b={year_month}&d={day}"
            web_scrape(url)

            # If the table is empty (playoffs/day 16 but there isn't a match in the Makuuchi division
            # Only care about first table "Makuuchi" (i.e. highest division), which will always appear first
            # hence we use .find instead of .find_all
            if soup.find(class_="tk_kaku").text != "Makuuchi":
                sumo_database["matches"][key] = None
                sumo_database["results"][key] = None
            else:
                # Find the table, convert to text and split up by newlines
                # Empty strings and the table title ("Makuuchi") are removed
                temp = [x for x in soup.find(class_="tk_table").get_text(",").split("\n,\n") if x not in ("", ',Makuuchi,')]
                # Clean the output
                temp = [re.sub("^,", "", re.sub(",$", "", re.sub(",+", ",", re.sub("\\s+", "", re.sub("\xa0", "Unknown", x))))) for x in temp]
                # Place in our database
                sumo_database["matches"][key] = temp

                # Now get the images, which are our win/loss/draw results. Sometimes videos are included, so we ignore
                # Replace the image names with their mappings
                temp = [multiple_replace(img["src"], rep_dict) for img in soup.find(class_="tk_table").find_all("img") if img.get("src") != "img/movie.png"]
                # Join every two results together (e.g. Win + Loss, Loss + Win...)
                sumo_database["results"][key] = ['-'.join(temp[i: i + 2]) for i in range(0, len(temp), 2)]

end_time = time.time()
print(str(round((end_time - start_time)/60, 1)) + " mins elapsed")
# 128.5 mins elapsed

# Check if we have the same number of matches as we do results
print(len(sumo_database["matches"]) == len(sumo_database["results"]))

# Now we want to convert this into a dataframe
sumo_matches = []
# Combine matches and results
for key in sumo_database["matches"].keys():
    # We can ignore where we don't have any data
    if sumo_database["matches"][key] is None:
        continue
    # Append our key + matches + results together, append to our list
    else:
        for i in range(len(sumo_database["matches"][key])):
            sumo_matches.append((key + "," +
                                 sumo_database["matches"][key][i] + "," +
                                 sumo_database["results"][key][i]
                                 ).split(","))

# Convert this list into a dataframe
sumo_matches = pd.DataFrame(sumo_matches)

# Tidying up
# Split columns
sumo_matches[["year_month", "day"]] = sumo_matches[0].str.split("_", expand=True)
sumo_matches[["win_loss_1", "win_loss_2"]] = sumo_matches[9].str.split("-", expand=True)
sumo_matches[["win_loss_1", "win_loss_binary_1"]] = sumo_matches["win_loss_1"].str.split(" ", expand=True)
sumo_matches[["win_loss_2", "win_loss_binary_2"]] = sumo_matches["win_loss_2"].str.split(" ", expand=True)

# Drop the columns we split into new ones
sumo_matches.drop([0, 9], axis=1, inplace=True)

# Rename columns which are only indexed
sumo_matches.rename(columns={1: "rank_1", 2: "name_1", 3: "basho_results_current_final_1", 4: "win_type",
                             5: "head_to_head_current_lifetime", 6: "rank_2", 7: "name_2",
                             8: "basho_results_current_final_2"}, inplace=True)

# Reorder
ordered_cols = ["year_month", "day", "win_loss_1", "win_loss_binary_1", "rank_1", "name_1",
                "basho_results_current_final_1", "win_type", "head_to_head_current_lifetime", "rank_2", "name_2",
                "basho_results_current_final_2", "win_loss_2", "win_loss_binary_2"]

sumo_matches = sumo_matches.reindex(ordered_cols, axis=1)

# Write to csv
sumo_matches.to_csv("sumo_matches_full.csv", index=False)

# Now look at Banzuke. Full results of the basho with extra statistics
start_time = time.time()
for year_month in sumo_database["years_months"]:

    print(year_month)

    # The table we're scraping combines all divisions together
    # Only select rows where we have a record of them in our matches. Do so using their rank
    # Select unique ranks which appeared in the Makuuchi basho
    makuuchi_ranks = pd.concat([sumo_matches[sumo_matches["year_month"] == year_month]["rank_1"],
                                sumo_matches[sumo_matches["year_month"] == year_month]["rank_2"]]
                               ).unique()

    # The first table we scrape does not have "previous" columns so throws up a 404 when web scraping
    # De-select "previous" stats for this banzuke, but select for the rest
    var = "" if year_month == "175710" else "spr=on&sps=on&"

    url = f"https://sumodb.sumogames.de/Banzuke.aspx?b={year_month}&heya=-1&shusshin=-1&h=on&sh=on&bd=on&hd=on&su=on&w=on&hr=on&ho=on&ch=on&cs=on&cr=on&{var}snr=on&sns=on&c=on&simple=on"
    web_scrape(url)

    # If there's an empty table add it as None (although not expecting any to be empty)
    if soup.find(class_="banzuke") is None:
        sumo_database["banzuke"][year_month] = None
        continue
    # If we don't have any ranks, this means we are scraping data that is older than when individual bout records began
    # i.e. pre-1909. Only the Banzuke exits (thus we don't know who competed in the top division, and who didn't)
    # Therefore, scrape everything
    elif not makuuchi_ranks.any():
        data = []
        table = soup.find("table", attrs={"class": "banzuke"})
        table_body = table.find("tbody")
        rows = table_body.find_all("tr")

        for row in rows:
            cols = row.find_all("td")
            data.append([x.text.strip() for x in cols])
    else:
        data = []
        table = soup.find("table", attrs={"class": "banzuke"})
        table_body = table.find("tbody")
        rows = table_body.find_all("tr")

        for row in rows:
            cols = row.find_all("td")
            # Otherwise, filter out if their rank doesnt appear in the ranks for bouts we collected that basho
            if cols[0].text.strip() not in makuuchi_ranks:
                pass
            else:
                data.append([x.text.strip() for x in cols])

    sumo_database["banzuke"][year_month] = data

# temp = [x for x in soup.find(class_="banzuke").get_text(",").split("\n,\n") if re.sub(r"^,([a-zA-Z0-9]+),.*", r"\1", x) in makuuchi_ranks]
# temp = [re.sub("^,", "", re.sub(",$", "", re.sub(",+", ",", re.sub("\\s+", "", re.sub("\xa0", "Unknown", x))))) for x in temp]
# sumo_database["banzuke"][year_month] = temp

end_time = time.time()
print(str(round((end_time - start_time)/60, 1)) + " mins elapsed")
# 23.2 mins elapsed

# Write full dictionary to JSON
with open("sumo_database_full.json", "w") as f:
    json.dump(sumo_database, f)

# Create index excluding first banzuke (we will need to manually add the missing "previous" columns)
index = list(sumo_database["banzuke"].keys())
index.remove("175710")

# Combining Banzuke
sumo_banzuke = []
for key in index:
    if sumo_database["banzuke"][key] is None:
        continue
    else:
        for i in range(len(sumo_database["banzuke"][key])):
            # Append key and banzuke results
            sumo_banzuke.append([key] + sumo_database["banzuke"][key][i])

# Convert list to dataframe
sumo_banzuke = pd.DataFrame(sumo_banzuke)

# Rename columns
sumo_banzuke.columns = ["year_month", "rank", "rikishi_name", "heya_stable", "shushin_birthplace", "dob", "debut",
                        "university", "height_weight", "current_rank_high", "hoshitori_basho_record", "career_rank_high",
                        "career_record", "prev_rank", "prev_basho_wins", "prev_basho_losses", "current_basho_wins",
                        "current_basho_losses", "next_basho_ranking", "next_basho_wins", "next_basho_losses"]

# Now, we do the same for out first record, but also append three empty strings for our "previous" columns
temp = []
for i in range(len(sumo_database["banzuke"]["175710"])):
    temp.append(["175710", "", "", ""] + sumo_database["banzuke"]["175710"][i])

# Convert to dataframe
temp = pd.DataFrame(temp)

# Rename columns
temp.columns = ["year_month", "prev_basho_wins", "prev_basho_losses", "prev_rank",
                "rank", "rikishi_name", "heya_stable", "shushin_birthplace", "dob", "debut", "university",
                "height_weight", "current_rank_high", "hoshitori_basho_record", "career_rank_high", "career_record",
                "current_basho_wins", "current_basho_losses", "next_basho_ranking", "next_basho_wins", "next_basho_losses"]

# Append these two datasets together
sumo_banzuke = sumo_banzuke.append(temp).sort_values(by=["year_month"])

# Inspecting the data after the fact, some sumo did not have ranks or hoshitori so they're shifted in the data left by 2
# in different places. Therefore, we need fix these. Can do so by simple renaming of columns

# Locate them
no_rank = [x for x in sumo_banzuke["rank"] if not re.findall("[0-9]", x)]
temp = sumo_banzuke[sumo_banzuke["rank"].isin(no_rank)]

# Add them to the end where the columns are both all None
temp.columns = ["year_month", "rikishi_name", "heya_stable", "shushin_birthplace", "dob", "debut", "university",
                "height_weight", "current_rank_high", "career_rank_high", "career_record", "prev_rank", "prev_basho_wins",
                "prev_basho_losses", "current_basho_wins", "current_basho_losses", "next_basho_ranking", "next_basho_wins",
                "next_basho_losses", "rank", "hoshitori_basho_record"]

# Append where "rank" was not a name, append fixed dataframe where "rank" was the name
sumo_banzuke = sumo_banzuke[~sumo_banzuke["rank"].isin(no_rank)].append(temp).sort_values(by=["year_month"])

# Write to csv
sumo_banzuke.to_csv("sumo_banzuke_full.csv", index=False)
