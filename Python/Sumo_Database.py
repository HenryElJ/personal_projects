import requests
from bs4 import BeautifulSoup
import pandas as pd
import re
import json
import time

# Sumo Bashos occur every odd month and are 15 days long
# Let's look back over the past 5 years
years_months = pd.date_range("2017-01", "2022-09", freq='2MS').strftime("%Y%m").tolist()
days = list(range(1, 16))
error_counter = 0 # Will become apparent in loop

# Empty database (i.e. dict) to fill
sumo_database = {}

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
        if soup.find(class_="tk_table") == None:
            continue
        else:
            pass

        # Only care about first table "Makuuchi" (i.e. highest division), hence we use .find instead of .find_all
        sumo_database[year_month + "-" + str(day)] = soup.find(class_="tk_table").text.strip().split("\n\n")

end_time = time.time()
elapsed_time = (end_time - start_time)/60
print(str(round(elapsed_time, 1)) + " mins elapsed") # ~9 mins

print(sumo_database["201701-1"])
print(sumo_database["202209-1"])

# Formatting of table changed (subtly), therefore do in post
# re.sub('(-\d+\))', r'\1 ',  # Add space )Here
# re.sub('(\d+-\d+ )', r' \1',  # Add space Here1-0

# Probably better to do as JSON
with open("sumo_database_raw.json", "w") as f:
    json.dump(sumo_database, f)

# with open("sumo_database.json", "r") as f:
# sumo_database = json.load(f)
