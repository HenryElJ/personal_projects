
import json, time, re, pandas as pd, numpy as np, xgboost as xgb
from datetime import datetime, timedelta

import dateutils
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from dateutil.relativedelta import relativedelta
from collections import Counter

pd.set_option('display.width', 250)
pd.set_option('display.max_columns', 50)

sumo_matches = pd.read_csv("sumo_matches_full.csv")
sumo_banzuke = pd.read_csv("sumo_banzuke_full.csv")

print(sumo_matches.tail())
print("*"*250)
print(sumo_banzuke.tail())

##################################################

# How do we want our data to be structured?
# We predict the most recent results using data from the previous 6 bashos (1 year).
# Feels like a good starting point

# "sumo_matches" formatting: East vs West. East always on left, West always on the right.
# When two East fight, higher ranked East on left.  When two West fight, higher ranked West on right.
# East is more "coveted" than the West. Will this matter?


# Rows in "sumo_matches" can be kept the same
# Initially I was considering having a (sort-of) cartesian mapping of opponents,
# where every sumo faces every other sumo - but X vs Y will be the the same as Y vs X
# Therefore, only need to predict either win_1 or
# Right? Test this.

# We need to have the same variables in our train as we do our test. We won't know certain things when we make our
# predictions

##################################################

# For now, create the simplest model just from our "sumo_matches"

# Most recent basho
test_index = [sumo_matches["year_month"].unique()[-1]]
# Previous 6 from most recent
train_index = list(sumo_matches["year_month"].unique()[-8:-2])

matches_cols = [
    "year_month"
    , "day"
    # , "win_loss_1"  # We can use "win_loss_binary_1" for predictions
    , "win_loss_binary_1"
    , "rank_1"
    , "name_1"
    , "basho_results_current_final_1"  # Only include current results
    # , "win_type" # Will not know this
    , "head_to_head_current_lifetime"  # Only include current results. Can be split as wins vs losses for sumo_1
    , "rank_2"
    , "name_2"
    , "basho_results_current_final_2"  # Only include current results
    # , "win_loss_2" # We are predicting "win_loss_binary_1"
    # , "win_loss_binary_2"  # We are predicting "win_loss_binary_1"
    ]

# Dataframe we will be working from
df = sumo_matches[sumo_matches["year_month"].isin(train_index + test_index)][matches_cols]

# Results format: W-L-Absences(W-L-Absences) # +: Playoff, -: Absence
# Not even considering draws for now...

# Only need to define pattern once as findall will return [(current), (overall)]
pattern = "(\d+)-(\d+)-?(\d+)?"

# Select first tuple (i.e. current), select first element (i.e. wins)
df["current_wins_1"] = df["basho_results_current_final_1"].str.findall(pattern).str[0].str[0]
# Select first tuple (i.e. current), select second element (i.e. losses)
df["current_losses_1"] = df["basho_results_current_final_1"].str.findall(pattern).str[0].str[1]

# Same for opponent
df["current_wins_2"] = df["basho_results_current_final_2"].str.findall(pattern).str[0].str[0]
df["current_losses_2"] = df["basho_results_current_final_2"].str.findall(pattern).str[0].str[1]

# Now for head to head record
# Results format: W[+- W]-L[+-L](W[+- W]-L[+-L]) # +: Playoff, -: Absence
# Not even considering draws for now...

# Only need to define pattern once as findall will return [(current), (overall)]
pattern = r"(\d+)(\[[0-9+-]+\])?-(\d+)(\[[0-9+-]+\])?"

# Select first tuple (i.e. current), select first element (i.e. wins)
df["head_to_head_wins_1"] = df["head_to_head_current_lifetime"].str.findall(pattern).str[0].str[0]
# Select first tuple (i.e. current), select thirs element (i.e. losses)
df["head_to_head_losses_1"] = df["head_to_head_current_lifetime"].str.findall(pattern).str[0].str[2]

# Drop columns we no longer need
df = df[[x for x in df.columns if x not in ["basho_results_current_final_1", "head_to_head_current_lifetime", "basho_results_current_final_2"]]]

print(df.head())

# ********** Very important **********
# The way our table is structured: current (and head to head) wins are updated simultaneously with the daily result
# Wins will be +1 for the winner, and losses will be +1 for the loser on the day of the match itself
# (which we won't know). This is most obvious to see on day 1

df.dtypes

# Change types
df = df.astype({
    "year_month": int
    , "day": int
    , "win_loss_binary_1": int
    , "rank_1": str
    , "name_1": str
    , "rank_2": str
    , "name_2": str
    , "current_wins_1": int
    , "current_losses_1": int
    , "current_wins_2": int
    , "current_losses_2": int
    , "head_to_head_wins_1": int
    , "head_to_head_losses_1": int
})

# Remove wins
df.loc[df["win_loss_binary_1"] == 1, ["current_wins_1", "current_losses_2", "head_to_head_wins_1"]] -= 1
# Remove losses
df.loc[df["win_loss_binary_1"] == 0, ["current_losses_1", "current_wins_2", "head_to_head_losses_1"]] -= 1

##################################################

banzuke_cols = [
    "year_month"  # Join condition
    , "rank"
    , "rikishi_name"  # Join condition
    # , "heya_stable"
    # , "shushin_birthplace"
    , "dob"  # Convert to age
    , "debut"  # Convert to duration of career
    # , "university"
    , "height_weight"  # Split into height_cm, weight_kg
    , "current_rank_high"
    , "hoshitori_basho_record"  # Split by day, convert to daily results? # Redundant?
    # , "career_rank_high"  # Won't know this (unless Y which is the highest, and you can't get demoted)
    # , "career_record"  # Need CURRENT career record. Have all the data so we could calculate this... Split into W/L/D
    # , "prev_rank"  # Don"t need if using previous bashos anyways
    # , "prev_basho_wins"  # Don"t need if using previous bashos anyways
    # , "prev_basho_losses"  # Don"t need if using previous bashos anyways
    , "current_basho_wins"
    , "current_basho_losses"
    # , "next_basho_ranking"  # Will not know this
    # , "next_basho_wins"  # Will not know this
    # , "next_basho_losses"  # Will not know this
    ]

df2 = sumo_banzuke[sumo_banzuke["year_month"].isin(train_index + test_index)][banzuke_cols]
df2["age"] = round((pd.to_datetime(df2["year_month"].astype(str), format="%Y%m") -
                    pd.to_datetime(df2["dob"].astype(str), format="%d.%m.%Y"))/timedelta(days=365))

df2["career_length"] = round((pd.to_datetime(df2["year_month"].astype(str), format="%Y%m") -
                              pd.to_datetime(df2["debut"].astype(str), format="%Y.%m"))/timedelta(days=365))

df2["height_cm"] = df2["height_weight"].str.findall(r"(\d+).*?(\d+).*?").str[0].str[0]
df2["weight_kg"] = df2["height_weight"].str.findall(r"(\d+).*?(\d+).*?").str[0].str[1]

# Add daily results
# O = Win, * = Loss, # = Loss by abscence, - = Absence
# Also weird % character
for i in range(1, 16):
    df2[f"result_day_{i}"] = df2["hoshitori_basho_record"].str.split("").str[i]\
        .replace("O", 1).replace("*", 0).replace("#", 0).replace("-", 0).replace("%", 0)

df2.drop(["dob", "debut", "height_weight", "hoshitori_basho_record"], axis=1, inplace=True)

df2 = df2.astype({
    "year_month": int
    , "rank": str
    , "rikishi_name": str
    , "current_rank_high": str
    , "current_basho_wins": int
    , "current_basho_losses": int
    , "age": int
    , "career_length": int
    , "height_cm": int
    , "weight_kg": int
    , "result_day_1": int
    , "result_day_2": int
    , "result_day_3": int
    , "result_day_4": int
    , "result_day_5": int
    , "result_day_6": int
    , "result_day_7": int
    , "result_day_8": int
    , "result_day_9": int
    , "result_day_10": int
    , "result_day_11": int
    , "result_day_12": int
    , "result_day_13": int
    , "result_day_14": int
    , "result_day_15": int
})

##################################################

# Left join and then pivot wider so we have one row
# Will need to do this twice for each sumo

# for year_month in set(df2["year_month"]):
#     for i in [1, 2]:
#
#         prefix = str(year_month) + "_"
#         suffix = f"_{i}"
#         temp = df2[df2["year_month"] == year_month]
#         temp = temp.add_prefix(prefix)
#         temp = temp.add_suffix(suffix)
#         temp.drop(prefix + "year_month" + suffix, axis=1, inplace=True)
#
#         df = df.merge(temp, left_on="name" + suffix, right_on=prefix + "rikishi_name" + suffix, how="left")

for i in [1, 2]:
    temp = df2[["year_month", "rikishi_name", "current_rank_high", "age", "career_length", "height_cm", "weight_kg"]]
    temp = temp.add_suffix(f"_{i}")
    df = df.merge(temp, left_on=["year_month", "name" + f"_{i}"],
                  right_on=["year_month" + f"_{i}", "rikishi_name" + f"_{i}"], how="left")

    df.drop(["year_month" + f"_{i}", "rikishi_name" + f"_{i}"], axis=1, inplace=True)

##################################################

sorted(list(set(
    df["rank_1"].append(df["rank_2"]).append(df["current_rank_high_1"]).append(df["current_rank_high_2"])
)))

# Split rankings into [J, M, K, S, O, Y] + Number + [East, West]
# Then one hot encode

for var in ["rank_", "current_rank_high_"]:
    for i in [1, 2]:

        # Extract level (J, M, K, S, O, Y) and OHE
        df = df.join(pd.get_dummies(df[f"{var}{i}"].str.findall("([JMKSOY])(\d{,2})?([ew])?").str[0].str[0],
                                    prefix=f"{var}level_{i}"))

        # Extract number
        df[f"{var}number_{i}"] = df[f"{var}{i}"].str.findall("([JMKSOY])(\d{,2})?([ew])?").str[0].str[1]

        # Extract East West (doesn't exist for career high)
        if var == "rank_":
            df = df.join(pd.get_dummies(df[f"{var}{i}"].str.findall("([JMKSOY])(\d{,2})?([ew])?").str[0].str[2],
                                        prefix=f"{var}east_west_{i}"))
        else:
            pass
        # Drop redundant vars (i.e. the one's we've split)
        df.drop(f"{var}{i}", axis=1, inplace=True)

df.dtypes

df["rank_number_1"] = df["rank_number_1"].replace("", 0).astype(int)
df["rank_number_2"] = df["rank_number_2"].replace("", 0).astype(int)
df["current_rank_high_number_1"] = df["current_rank_high_number_1"].replace("", 0).astype(int)
df["current_rank_high_number_2"] = df["current_rank_high_number_2"].replace("", 0).astype(int)

df.drop(["name_1", "name_2"], axis=1, inplace=True)

##################################################

index = [x for x in df.columns if x != "win_loss_binary_1"]

x_train = df[df["year_month"].isin(train_index)][index]
y_train = df[df["year_month"].isin(train_index)]["win_loss_binary_1"]

x_test = df[df["year_month"].isin(test_index)][index]
y_test = df[df["year_month"].isin(test_index)]["win_loss_binary_1"]

# Already close enough to a 80:20 test:train split (i.e. 83:17)
clf = LogisticRegression(penalty="l1", dual=False, tol=0.001, C=1.0, fit_intercept=True,
                         intercept_scaling=1, class_weight="balanced", random_state=None,
                         solver="liblinear", max_iter=1000, multi_class="ovr", verbose=0)

clf.fit(x_train, np.ravel(y_train.values))

y_pred = clf.predict_proba(x_test)
y_pred = y_pred[:,1]
accuracy_score(y_test, np.round(y_pred))

##################################################

dtest = xgb.DMatrix(x_test, y_test, feature_names=x_test.columns)
dtrain = xgb.DMatrix(x_train, y_train, feature_names=x_train.columns)

param = {"verbosity": 1,
         "objective": "binary:hinge",
         "feature_selector": "shuffle",
         "booster": "gblinear",
         "eval_metric": "error",
         "learning_rate": 0.05}

evallist = [(dtrain, "train"), (dtest, "test")]

num_round = 1000
bst = xgb.train(param, dtrain, num_round, evallist)

y_pred_xgb = bst.predict(dtest)

accuracy_score(y_test, np.round(y_pred_xgb))

