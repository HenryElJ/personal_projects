import requests
from bs4 import BeautifulSoup
import pandas as pd
import json
import time
import re

# Sumo Bashos occur every odd month and are 15 days long
# Let's look back over the past 5 years
years_months = pd.date_range("2017-01", "2022-09", freq='2MS').strftime("%Y%m").tolist()
days = list(range(1, 16))
error_counter = 0 # Will become apparent in loop


# I don't want to chain .replace().replace().replace()...
def multiple_replace(string, rep_dict):
    pattern = re.compile("|".join([re.escape(k) for k in sorted(rep_dict, key=len, reverse=True)]), flags=re.DOTALL)
    return pattern.sub(lambda x: rep_dict[x.group(0)], string)

# hoshi_shiro = WIN (white circle)
# hoshi_kuro = LOSS (black circle)
# hoshi_fusensho = Retirement/Absence WIN (white square)
# hoshi_fusenpai = Retirement/Absence LOSS (black square)
# hoshi yasumi = Out of basho (dash)


rep_dict = {"img/": "", ".gif": "",
            "hoshi_shiro": "WIN: 1", "hoshi_kuro": "LOSS: 0",
            "hoshi_fusensho": "WIN (due to absence): 1", "hoshi_fusenpai": "LOSS (due to absence): 0"}

# Empty database (i.e. dict) to fill
sumo_matches = {}
sumo_results = {}

start_time = time.time()

for year_month in years_months:

    for day in days:

        print(year_month + "-" + str(day))
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
            print(f"Error counter = {error_counter}")
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
        sumo_matches[year_month + "-" + str(day)] = soup.find(class_="tk_table").text.strip().split("\n\n")

        # WIN/LOSS stored as an .gif image (wild choice...). Need to extract and convert
        tmp = []
        for img in soup.find(class_="tk_table").find_all("img"):
            # Sometimes includes video clips. Ignore
            if img.get("src") == "img/movie.png":
                pass
            else:
                tmp.append(multiple_replace(img.get("src"), rep_dict))

        sumo_results[year_month + "-" + str(day)] = [' - '.join(tmp[i: i + 2]) for i in range(0, len(tmp), 2)]

end_time = time.time()
elapsed_time = (end_time - start_time)/60
print(str(round(elapsed_time, 1)) + " mins elapsed")
# ~9 mins

# Most definitely a better way to do this check...
print(len(sumo_matches) == len(sumo_results))

for key in sumo_matches.keys():
    print(len(sumo_matches[key]) - 1 == len(sumo_results[key]))

# Inspect
print(sumo_matches["201701-1"])
print(sumo_results["201701-1"])

print(sumo_matches["202209-1"])
print(sumo_results["202209-1"])

# Export as JSON
with open("sumo_database_matches.json", "w") as f:
    json.dump(sumo_matches, f)

with open("sumo_database_results.json", "w") as f:
    json.dump(sumo_results, f)

# with open("sumo_database_matches.json", "r") as f:
# sumo_matches = json.load(f)

# with open("sumo_database_results.json", "r") as f:
# sumo_results = json.load(f)

# Formatting of table is (subtly) inconsistent, therefore do in post

# re.sub('(-\d+\))', r'\1 ',  # Add space )Here
# re.sub('(\d+-\d+ )', r' \1',  # Add space Here1-0

# Also need to explore how to properly tabulate this data. Currently data looks like this:

# 201701-1
# ['Makuuchi', 'Y1e Kakuryu1-0 (5-6-4)uwatedashinage20-1 (23-4)K1w Tochinoshin0-1 (0-6-9)',...,
# 'M15e Chiyoo0-1 (7-8)utchari0-4 (3-5)M16e Osunaarashi1-0 (4-11)']

# 202209-1
# ['Makuuchi', 'Y1e Terunofuji1-0 (5-5-5)yorikiri9-0K2w Kiribayama0-1 (9-6)',...,
# 'J1e Shimanoumi0-1 (4-11)yorikiri0-1M16w Hiradoumi1-0 (7-8)']
