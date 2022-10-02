
import requests
from bs4 import BeautifulSoup
import pandas as pd
import json
import time
import re

# Code has gotten quite "niche" and complicated. Will need thorough commenting to explain
# especially regarding list comprehensions

# Sumo Bashos occur every odd month and are 15 days long (+ playoffs)
# Records begin 1909 Natsu

sumo_database = {"years_months": [], "days": [], "basho_names": [], "matches": {}, "results": {}}

url = "https://sumodb.sumogames.de/Banzuke.aspx"
r = requests.get(url)
while not r.ok:
    r = requests.get(url)
soup = BeautifulSoup(r.text, features="html.parser")

for i in soup.find(class_="bashoselect").find_all("option"):
    sumo_database["years_months"] += [i["value"]]
    sumo_database["basho_names"] += [i.text]

# Now we need the number of days. Some have 10 or less, others have 15, and Playoffs are included on a separate day page
# https://sumodb.sumogames.de/Banzuke.aspx?b=YYYYMM

start_time = time.time()
for i in sumo_database["years_months"]:

    print(i, end="\r")

    url = "https://sumodb.sumogames.de/Banzuke.aspx?b=" + i
    r = requests.get(url)
    # If Error 404
    error_count = 0
    while not r.ok:
        error_count += 1
        print(f"Error 404: {error_count} attempts", end="\r")
        r = requests.get(url)

    soup = BeautifulSoup(r.text, features="html.parser")
    # If no days, none (do not omit, as we need same length with years_months (to properly filter out/index later))
    if soup.find(class_="daytable") is None:
        sumo_database["days"].append(None)
        continue
    else:
        sumo_database["days"] += [["".join(re.findall("d=(\d+)$", i["href"])) for i in soup.find(class_="daytable").find_all("a") if "Results" in i["href"]]]

end_time = time.time()
print(str(round((end_time - start_time)/60, 1)) + " mins elapsed")
# ~13.5 mins elapsed

# Check
print(len(sumo_database["years_months"]) == len(sumo_database["days"]) == len(sumo_database["basho_names"]))

# hoshi_shiro = WIN (white circle)
# hoshi_kuro = LOSS (black circle)
# hoshi_hikiwake = DRAW (white triangle)
# hoshi_fusensho = Retirement/Absence WIN (white square)
# hoshi_fusenpai = Retirement/Absence LOSS (black square)
# hoshi yasumi = Out of basho (dash)

rep_dict = {"img/": "", ".gif": "",
            "hoshi_shiro": "WIN 1",
            "hoshi_kuro": "LOSS 0",
            "hoshi_fusensho": "WIN_ABSENCE 1",
            "hoshi_fusenpai": "LOSS_ABSENCE 0",
            "hoshi_hikiwake": "DRAW 0"}


# I don't want to chain .replace().replace().replace()...
def multiple_replace(string, rep_dict):
    pattern = re.compile("|".join([re.escape(k) for k in sorted(rep_dict, key=len, reverse=True)]), flags=re.DOTALL)
    return pattern.sub(lambda x: rep_dict[x.group(0)], string)

# Index where there are days present
# index = [index for index in range(len(sumo_database["days"])) if sumo_database["days"][index] is not None]


start_time = time.time()

for i in range(len(sumo_database["years_months"])):

    year_month = sumo_database["years_months"][i]

    if sumo_database["days"][i] is None:
        sumo_database["matches"][year_month] = None
        sumo_database["results"][year_month] = None
        continue
    else:
        for day in sumo_database["days"][i]:

            print(year_month + '_' + str(day))

            # URL format: "https://sumodb.sumogames.de/Results.aspx?b=YYYYMM&d=D"
            url = "https://sumodb.sumogames.de/Results.aspx?b=" + year_month + "&d=" + str(day)

            r = requests.get(url)
            # If 404 error page
            error_count = 0
            while not r.ok:
                error_count += 1
                print(f"Error 404: {error_count} attempts", end="\r")
                r = requests.get(url)

            print("Access okay")
            soup = BeautifulSoup(r.text, features="html.parser")

            # We get access to the webpage, but the table is empty. Most recently due to COVID-19, Bashos were cancelled
            # OR we are on day 16 and there isn't a playoff match for the Makuuchi division
            # Only care about first table "Makuuchi" (i.e. highest division), hence we use .find instead of .find_all
            if soup.find(class_="tk_kaku").text != "Makuuchi":
                sumo_database["matches"][year_month + "_" + str(day).rjust(2, "0")] = None
                sumo_database["results"][year_month + "_" + str(day).rjust(2, "0")] = None
                continue
            else:
                temp = [x for x in soup.find(class_="tk_table").get_text(",").split("\n,\n") if x not in ("", ',Makuuchi,')]
                temp = [re.sub("^,", "", re.sub(",$", "", re.sub(",+", ",", re.sub("\\s+", "", re.sub("\xa0", "Unknown", x))))) for x in temp]
                sumo_database["matches"][year_month + "_" + str(day).rjust(2, "0")] = temp

                temp = [multiple_replace(img["src"], rep_dict) for img in soup.find(class_="tk_table").find_all("img") if img.get("src") != "img/movie.png"]
                sumo_database["results"][year_month + "_" + str(day).rjust(2, "0")] = ['-'.join(temp[i: i + 2]) for i in range(0, len(temp), 2)]

end_time = time.time()
print(str(round((end_time - start_time)/60, 1)) + " mins elapsed")
# 128.5 mins elapsed

# Most definitely a better way to do this check...
print(len(sumo_database["matches"]) == len(sumo_database["results"]))

# Export as JSON
with open("sumo_database_full.json", "w") as f:
    json.dump(sumo_database, f)

# Checkpoint ####################

# with open("sumo_database_full.json", "r") as f:
#     sumo_database = json.load(f)

sumo_data = []
# Combine matches and results
for key in sumo_database["matches"].keys():
    if sumo_database["matches"][key] is None:
        continue
    else:
        for i in range(len(sumo_database["matches"][key])):
            sumo_data.append((key + "," +
                              sumo_database["matches"][key][i] + "," +
                              sumo_database["results"][key][i]).split(","))

sumo_data = pd.DataFrame(sumo_data)

sumo_data[["year_month", "day"]] = sumo_data[0].str.split('_', expand=True)
sumo_data[["win_loss_1", "win_loss_2"]] = sumo_data[9].str.split('-', expand=True)

sumo_data = sumo_data.drop(0, axis=1)
sumo_data = sumo_data.drop(9, axis=1)

sumo_data.rename(columns={1: "rank_1", 2: "name_1", 3: "basho_results_current_final_1", 4: "win_type", 5: "head_to_head_current_lifetime",
                          6: "rank_2", 7: "name_2", 8: "basho_results_current_final_2"}, inplace=True)

ordered_cols = ["year_month", "day", "win_loss_1", "rank_1", "name_1", "basho_results_current_final_1", "win_type",
                "head_to_head_current_lifetime", "rank_2", "name_2", "basho_results_current_final_2", "win_loss_2"]

sumo_data = sumo_data.reindex(ordered_cols, axis=1)

print(sumo_data)

sumo_data.to_csv('sumo_database.csv', index=False)

# Future work:
# Add different divisions
# Scrape sumo profiles
# Function to update