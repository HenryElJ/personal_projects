# Featured Highlights

### Cellular automata:

* Dead cell = 0, Alive cell = 1.

* Moore neighbourhood = (N, E, S, W, NE, NW, SE, SW).

* Von Neumann neighbourhood = (N, E, S, W).

* Diagonal neighbourhood = (NE, NW, SE, SW).

## (Two Steps Back) Cellular Automata Depth 200

Inspiration taken from [Softolofy's Blog - Two Step Back Cellular Automata](https://softologyblog.wordpress.com/2018/01/27/two-steps-back-cellular-automata) (which in turn was inspired by [Charlie Deck BigBlueBoo's Tumblr](https://bigblueboo.tumblr.com/post/109303390974/cellular-automata-alien-life-this-rule-takes-the)).

### Rules:

"Each cell is updated by counting the neighbours 2 cells either side of it and itself (5 cells) and the same 5 cells in the previous generation. This gives you a possible count of active cells between 0 and 10. The count is used into a rule array for the new cell state.

For example, if your rule array is rule[1,0,0,0,0,1,0,1,1,0,1] and the cell has 5 neighbour cells that are alive, then the new cell would be alive too (the rule counts start at 0, so the 6th entry in the rule array is for 5 active neighbours and that entry is 1)." - Softology's Blog

Here's a selection of the plots produced:

<p align="center">
	<img src = "/Images/two_steps_back_1.jpg" width = "300">
	<img src = "/Images/two_steps_back_2.jpg" width = "300">
	<img src = "/Images/two_steps_back_3.jpg" width = "300">
</p>

## Fredkin Replicator

Cellular automata which uses the Von Neumann neighbourhood of cells. 

### Rules:

If a cell has an even number of neighbours that are alive, then the cell will die. If a cell has an odd number of neighbours that are alive, then it will be alive.

<p align="center">
  <img src="/Images/fredkin.gif">
</p>

## Samasta Mandala

Inspiration taken from [Github: Derstefan's SamastaMandala](https://github.com/Derstefan/SamastaMandala).

Starting with a single point in the middle of the grid, and applying our array of rules (as seen with the two steps back cellular automata) for diagonal, Moore, and Von Neumann neighbourhoods.

<p align="center">
  <img src="/Images/Rule_72_011000111.gif">
</p>

## Game of Life

Perhaps the most famous example of cellular automata (and my first venture into coding it).

### Rules:

* Using Moore's neighbourhood.

* Alive cells with fewer than two live neighbours dies (underpopulation).

* Alive cells with two or three live neighbours lives.

* Alive cells with more than three live neighbours dies (overpopulation).

* Dead cells with exactly three live neighbours becomes a live cell (reproduction).

Another variation on this is Brian's Brain, which has a transition state from alive to dead cells.

This code culminated in a Shiny App I created where you can create your own Game of Life .gif based on a lexicon of over 700 "shapes."

[Shiny Apps - Game of Life](https://henryelj.shinyapps.io/game_of_life/?_ga=2.216138582.118198322.1664441847-1469572834.1664441847)

## Langtons Ant

Cellular automata  which has an arbitrary square is denoted as the "ant"  which can travel in any of the four directions (N, E, S, W). Squares on a grid are coloured either black or white based on the ant's route.

### Rules:

* At a white (dead) square, turn 90 degrees clockwise, flip the colour of the square, move forward one unit.

* At a black (alive) square, turn 90 degrees counter-clockwise, flip the colour of the square, move forward one unit.

![](/Images/Rplot10837.png)
![](/Images/Rplot13937.png)
![](/Images/Rplot123157.png)
![](/Images/Rplot70273.png)
![](/Images/Rplot36437.png)
![](/Images/Rplot32734.png)

## Turmite

Similar to Langton's ant.

### Rules:

* Turn on the spot (by some multiple of 90 degrees).

* Change the colour of the square.

* Move forward one square.

![](/Images/Standard.png)
![](/Images/Highway.png)
![](/Images/Chaotic.png)
![](/Images/Expanding_Frame.png)

## Rock Paper Scissors

Generate a random tri-coloured grid (with each colour corresponding to rock, paper, or scissors). If a cell is surrounded (Moore neighbourhood) by at least n (threshold you determine e.g. 4) number of cells that "beat" it, then it becomes the colour of that cell (e.g. rock surrounded by at least 4 paper -> the rock cell becomes paper). 

Iteratively the cellular automata converges into a repeating spiral motion.

<p align="center">
  <img src="/Images/Rock_Paper_Scissors.gif">
  <img src="/Images/Rock_Paper_Scissors_Lizard_Spock.gif">
</p>

## Sandpiles

Cellular automaton starting with a finite grid and n number of grains placed all in the centre cell (called a slope). This slope builds up as "grains of sand" pile, until the slope exceeds a specific threshold value (e.g. 4) at which time that site collapses transferring sand into the adjacent sites (Von Neumann neighbourhood), increasing their slope. This then repeats.

<p align="center">
	<img src = "/Images/Sandpile_1e6.png" width = "500">
</p>

## Image Coding

Takes two black and white images (one as "start", the other as "end"), determines the range of greyscale colour values for each (creating a map of pixels and their values) and iteratively changes the pixels to shift in the direction from "start" to "end."

<p align="center">
	<img src = "/Images/transition_50fps.gif" width = "500">
</p>
