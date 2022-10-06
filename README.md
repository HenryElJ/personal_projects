# Personal Projects

A collection of personal projects and interesting coding problems.

## Python

### Practice Python Questions

Completed all 40 exercises from [Practice Python](https://www.practicepython.org).

### Sumo Database

#### sumo_database.py

Web scraping [Sumo Reference](https://sumodb.sumogames.de/Default.aspx) for the banzuke (overall tournament results) and torikumi (daily basho results). Data has been exported as both the JSON and cleaned + tabulated CSV:

* **sumo_database_full.json**

	* Full data dictionary containing:
	
		* Year and month
		* Name
		* Number of days
		* Matches
		* Match results
		* Overall tournament results
		* Rikishi (sumo wrestler) stats
		* Makuuchi (highest division) win loss matrices

* **sumo_maches_full.csv**

	* Containing the results of all sumo matches from 1909-06 to 2022-09 (makuuchi division only).

* **sumo_banzuke_full.csv**

	* Containing the results of all sumo tournaments from 1757-10 to 2022-09 (all divisions up to 1909-01, makuuchi division only from 1909-06 to 2022-09), and rikishi (sumo wrestler) stats.
	
* **sumo_win_loss_matrix_full.csv**

	* All available win/loss matrices for the Makuuchi (highest) division.

This is useful as there currently doesn't exist any tabulated data for this large a collection of results (only done by day or by basho).

#### sumo_analysis.py

Attempting to predict sumo matches from the webscraped data. Primarily using sumo_maches_full.csv and sumo_banzuke_full.csv.

## R

**Please see R/README.md for Featured Highlights of the code described below.**

### Project Euler

Completed first 50 problems from [Project Euler](https://projecteuler.net).

### Numberphile

Attempting to reconstruct interesting mathematical concepts and code featured in [Numberphile](https://www.youtube.com/c/numberphile) videos, along with other mini-projects (mostly focused on cellular automata).

### Game of Life Functions

Necessary functions used to run [Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).

### Game of Life

Wrapper to run [Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).

### IMD England

Reconstructing the [Index of Multiple Deprivation](https://en.wikipedia.org/wiki/Multiple_deprivation_index) for England, using open-source data from the Office for National Statistics (ONS).

### Image Transition Function

Function which takes two images (b\&w) and transitions from the first to the second - producing a looping GIF as the output.

### Image Cellular Automata

Takes an image (b\&w) and uses it as the starting grid for Game of Life.
