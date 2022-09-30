
import requests
from bs4 import BeautifulSoup
import pandas as pd
import json
import time
import re

# Sumo Bashos occur every odd month and are 15 days long (have not considered playoffs)
# Let's look back from 1958-present (first year where there were 6 bashos)
years_months = pd.date_range("1958-01", "2022-09", freq='2MS').strftime("%Y%m").tolist()
days = list(range(1, 16))
# Will become apparent in loop
error_counter = 0
error_range = [0, 0]

# I don't want to chain .replace().replace().replace()...
def multiple_replace(string, rep_dict):
    pattern = re.compile("|".join([re.escape(k) for k in sorted(rep_dict, key=len, reverse=True)]), flags=re.DOTALL)
    return pattern.sub(lambda x: rep_dict[x.group(0)], string)

# hoshi_shiro = WIN (white circle)
# hoshi_kuro = LOSS (black circle)
# hoshi_fusensho = Retirement/Absence WIN (white square)
# hoshi_fusenpai = Retirement/Absence LOSS (black square)
# hoshi yasumi = Out of basho (dash)
# hoshi_hikiwake = Draw


rep_dict = {"img/": "", ".gif": "",
            "hoshi_shiro": "WIN 1", "hoshi_kuro": "LOSS 0",
            "hoshi_fusensho": "WIN_ABSENCE 1", "hoshi_fusenpai": "LOSS_ABSENCE 0",
            "hoshi_hikiwake": "DRAW 0"}

# Empty database (i.e. dict) to fill
sumo_matches = {}
sumo_results = {}

start_time = time.time()

for year_month in years_months:

    for day in days:

        print(year_month + "_" + str(day))
        # URL format: "https://sumodb.sumogames.de/Results.aspx?b=YYYYMM&d=D"
        url = "https://sumodb.sumogames.de/Results.aspx?b=" + year_month + "&d=" + str(day)

        r = requests.get(url)

        # If 404 error page, try again
        # Potentially dangerous/infinite (??) If for instance the page simply doesn't exist.
        # When error occurs, min re-requests = ~23, max re-requests = ~125
        while not r.ok:
            print("Error 404. Trying again")
            r = requests.get(url)
            error_counter += 1

        if error_counter == 0:
            pass
        else:
            if error_range[0] == 0:
                error_range[0] = error_counter
                error_range[1] = error_counter
            elif error_counter < error_range[0]:
                error_range[0] = error_counter
            elif error_counter > error_range[1]:
                error_range[1] = error_counter
            else:
                pass

            print(f"Error counter = {error_counter}\nError range: {error_range}")
            error_counter = 0

        print("Access okay")
        r_html = r.text
        soup = BeautifulSoup(r.text, features="html.parser")

        # We get access to the webpage, but the table is empty
        # Most recently due to COVID-19, Bashos were cancelled
        if soup.find(class_="tk_table") is None:
            continue
        else:
            pass

        # Only care about first table "Makuuchi" (i.e. highest division), hence we use .find instead of .find_all
        sumo_matches[year_month + "_" + str(day).rjust(2, "0")] = soup.find(class_="tk_table").text.strip().split("\n\n")

        # WIN/LOSS stored as an .gif image (wild choice...). Need to extract and convert
        tmp = []
        for img in soup.find(class_="tk_table").find_all("img"):
            # Sometimes includes video clips. Ignore
            if img.get("src") == "img/movie.png":
                pass
            else:
                tmp.append(multiple_replace(img.get("src"), rep_dict))

        sumo_results[year_month + "_" + str(day).rjust(2, "0")] = [' - '.join(tmp[i: i + 2]) for i in range(0, len(tmp), 2)]

end_time = time.time()
elapsed_time = (end_time - start_time)/60
print(str(round(elapsed_time, 1)) + " mins elapsed")
# (201701 to 202209) ~9 mins
# (205801 to 202209) ~97 mins

# Most definitely a better way to do this check...
print(len(sumo_matches) == len(sumo_results))

for key in sumo_matches.keys():
    if len(sumo_matches[key]) - 1 != len(sumo_results[key]):
        print(key)
    else:
        pass


# Inspect
print(sumo_matches["202209_01"])
print(sumo_results["202209_01"])

sumo_database = {"matches": sumo_matches, "results": sumo_results}

# Export as JSON
with open("sumo_database_matches.json", "w") as f:
    json.dump(sumo_matches, f)

with open("sumo_database_results.json", "w") as f:
    json.dump(sumo_results, f)

with open("sumo_database_full.json", "w") as f:
    json.dump(sumo_database, f)

# Open JSON
# with open("sumo_database_matches.json", "r") as f:
#     sumo_matches = json.load(f)
#
# with open("sumo_database_results.json", "r") as f:
#     sumo_results = json.load(f)

########## Checkpoint ##########

with open("sumo_database_full.json", "r") as f:
    sumo_database = json.load(f)

# Remove "Makuuchi" from match data
for matches in sumo_database["matches"].values():
    matches.pop(0)

# Clean match strings and add results
for key in sumo_database["matches"].keys():
    for i in range(len(sumo_database["matches"][key])):
        sumo_database["matches"][key][i] = re.sub("\s{2,}", " ",
                                                  re.sub("(.*) - (.*)", r"\1 ", sumo_database["results"][key][i]) +
                                                  re.sub("([^a-zA-Z]{3,})", r" \1 ", sumo_database["matches"][key][i]).strip() +
                                                  re.sub("(.*) - (.*)", r" \2", sumo_database["results"][key][i]))

sumo_df = pd.DataFrame.from_dict(sumo_database["matches"], orient="index").add_prefix("match_")

sumo_df.index.name = 'yearmonth_day'
sumo_df.reset_index(inplace=True)

sumo_df = pd.wide_to_long(sumo_df, stubnames="match", i="yearmonth_day", j="match_no", sep="_").sort_values(by=["yearmonth_day", "match_no"])
sumo_df.reset_index(inplace=True)

# See an example cell
print(sumo_df.iat[0, 0])
# Python man.....

# "match" should always follow this format
# E.g. "WIN 1 Y1e Kakuryu 1-0 (5-6-4) uwatedashinage 20-1 (23-4) K1w Tochinoshin 0-1 (0-6-9) LOSS 0"
# "[A-Z]+ \d [a-zA-Z0-9]+ [a-zA-Z]+ [^a-zA-Z]+ [a-zA-Z]+ [^a-zA-Z]+ [a-zA-Z0-9]+ [a-zA-Z]+ [^a-zA-Z]+ [A-Z]+ \d"

# <input>:8: SettingWithCopyWarning:
# A value is trying to be set on a copy of a slice from a DataFrame
# See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
for i in range(len(sumo_df["match"])):

    if sumo_df["match"][i] is None:
        pass
    else:
        sumo_df["match"][i] = re.sub("([A-Z_]+) (\d) ([a-zA-Z0-9]+) ([a-zA-Z]+) ([^a-zA-Z]+) ([a-zA-Z]+) ([^a-zA-Z]+) ([a-zA-Z0-9]+) ([a-zA-Z]+) ([^a-zA-Z]+) ([A-Z_]+) (\d)",
                                     r"\1,\2,\3,\4,\5,\6,\7,\8,\9,\10,\11,\12",
                                     sumo_df["match"][i])
# Above takes a while...

new_cols = ["win_loss_1", "win_loss_binary_1", "rank_1", "name_1", "basho_current_final_result_1",
            "win_type", "head_to_head_current_present",
            "rank_2", "name_2", "basho_current_final_result_2", "win_loss_2", "win_loss_binary_2"]

sumo_df[new_cols] = sumo_df["match"].str.split(",", expand=True)
sumo_df.drop(labels="match", axis=1, inplace=True)

sumo_df = sumo_df[sumo_df["win_type"].notnull()]

sumo_df.to_csv('sumo_database_195801_202209.csv', index=False)

# Future work:
# Add playoffs (day 16)
# Add different divisions
# Go further back (fiddly url work?)
# Scrape sumo profiles
