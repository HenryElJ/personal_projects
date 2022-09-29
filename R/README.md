# Featured Highlights

(Note, for cellular automata we have: Dead cell = 0, Alive cell = 1)

## (Two Steps Back) Cellular Automata Depth 200

Inspiration taken from [Softolofy's Blog - Two Step Back Cellular Automata](https://softologyblog.wordpress.com/2018/01/27/two-steps-back-cellular-automata) (which in turn was inspired by [Charlie Deck BigBlueBoo's Tumblr](https://bigblueboo.tumblr.com/post/109303390974/cellular-automata-alien-life-this-rule-takes-the))

Rules:

"Each cell is updated by counting the neighbours 2 cells either side of it and itself (5 cells) and the same 5 cells in the previous generation. This gives you a possible count of active cells between 0 and 10. The count is used into a rule array for the new cell state.

For example, if your rule array is rule[1,0,0,0,0,1,0,1,1,0,1] and the cell has 5 neighbour cells that are alive, then the new cell would be alive too (the rule counts start at 0, so the 6th entry in the rule array is for 5 active neighbours and that entry is 1)." - Softology's Blog

Here's a selection of the plots produced:

![](/Images/two_steps_back_1.jpg | width = 100)

![](/Images/two_steps_back_2.jpg)

![](/Images/two_steps_back_3.jpg)

## Fredkin Replicator

Cellular automata which uses the Von Neumann neighbourhood of cells (i.e. North, East, South West). 

Rules:

If a cell has an even number of neighbours that are alive, then the cell will turn die. If a cell has an odd number of neighbours that are alive, then it will be alive.

![](/Images/fredkin.gif)

## Samasta Mandala

Inspiration taken from [Github: Derstefan's SamastaMandala](https://github.com/Derstefan/SamastaMandala)

Starting with a single point in the middle of the grid, and applying our array of rules (as seen with the two steps back cellular automata) for diagonal, Moore, and Von Neumann neighbourhoods.

![](/Images/Rule 72 - 011000111.gif)

## Game of Life

Perhaps the most famous example of cellular automata (and my first venture into its coding).

Rules:

Alive cells with fewer than two live neighbours dies (underpopulation).

Alive cells with two or three live neighbours lives.

Alive cells with more than three live neighbours dies (overpopulation).

Dead cells with exactly three live neighbours becomes a live cell (reproduction).

Note: Using Moore's neighbourhood (North, North East, East, South East, South, South West, West, North West)

This code culminated in a Shiny App I created where you can create your own Game of Life .gif based on a lexicon of over 700 "shapes."

[Shiny Apps - Game of Life](https://henryelj.shinyapps.io/game_of_life/?_ga=2.216138582.118198322.1664441847-1469572834.1664441847)

## Langtons Ant

Cellular automata  which has an arbitrary square is denoted as the "ant"  which can travel in any of the four cardinal directions. Squares on a grid are coloured either black or white based on the ant's route.

Rules:

At a white (dead) square, turn 90° clockwise, flip the colour of the square, move forward one unit.

At a black (alive) square, turn 90° counter-clockwise, flip the colour of the square, move forward one unit.

![](/Images/Rplot10837.png)
![](/Images/Rplot13937.png)
![](/Images/Rplot123157.png)
![](/Images/Rplot70273.png)
![](/Images/Rplot36437.png)
![](/Images/Rplot32734.png)

## Turmite

Similar to Langton's ant.

Rules:

Turn on the spot (by some multiple of 90°)

Change the colour of the square

Move forward one square.

![](/Images/Standard.png)
![](/Images/Highway.png)
![](/Images/Chaotic.png)
![](/Images/Expanding Frame.png)

## Rock Paper Scissors

Generate a random tri-coloured grid (with each colour corresponding to rock, paper, or scissors). If a cell is surrounded (Moore neighbourhoos) by at least n (threshold you determine e.g. 4) number of cells that "beat" it, then it becomes the colour of that cell (e.g. rock surrounded by at least 4 paper -> the rock cell becomes paper). 

Iteratively the cellular automata converges into a repeating spiral motion.

![](/Images/Rock Paper Scissors.gif.gif)
![](/Images/Rock Paper Scissors Lizard Spock.gif)

## Sandpiles

Cellular automaton starting with a finite grid and n number of grains placed all in the centre cell (called a slope). This slope builds up as "grains of sand" pile, until the slope exceeds a specific threshold value (e.g. 4) at which time that site collapses transferring sand into the adjacent sites (Von Neumann neighbourhood), increasing their slope. This then repeats.

![](/Images/Sandpile_1e6.png)

## Image Coding

Takes two black and white images (one as "start", the other as "end"), determines the range of greyscale colour values for each (creating a map of pixels and their values) and iteratively changes the pixels to shift in the direction from "start" to "end."

![](/Images/transition_50fps.gif)