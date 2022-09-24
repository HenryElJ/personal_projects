# Author: Henry El-Jawhari
# Date: Sept. 2022
# Exercises taken from: https://www.practicepython.org

# Exercise 1 ##################################################

# Create a program that asks the user to enter their name and their age.
# Print out a message addressed to them that tells them the year that they will turn 100 years old.
# The expectation is that you explicitly write out the year (and therefore be out of date the next year).

name = input("Please enter your name > ")
age = input("Next, please enter your age > ")

print(f"Hello {name}, you will turn 100 in the year {100 - int(age) + 2022}")

# Exercise 2 ##################################################

# Ask the user for a number.
# Depending on whether the number is even or odd, print out an appropriate message to the user.

number = input("Please enter a random number > ")

print(f'This number is {"even" if int(number) % 2 == 0 else "odd"}')

# Exercise 3 ##################################################

# Take a list, say for example this one:

# a = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]

# and write a program that prints out all the elements of the list that are less than 5.

a = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]

print([num for num in a if num < 5])

# Exercise 4 ##################################################

# Create a program that asks the user for a number and then prints out a list of all the divisors of that number.

number = input("Please enter a random number > ")

b = []

for i in range(1, int(number) + 1):
    if int(number) % i == 0:
        b.append(i)
    else:
        pass

print(f"Divisors of {number} are: " + str(b))

# Exercise 5 ##################################################

# Take two lists, say for example these two:

#   a = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
#   b = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]

# and write a program that returns a list that contains only the elements that are common between the lists
# (without duplicates). Make sure your program works on two lists of different sizes.

a = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
b = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]

print(list(set([num for num in a if num in b])))

# Exercise 6 ##################################################

# Ask the user for a string and print out whether this string is a palindrome or not.
# A palindrome is a string that reads the same forwards and backwards.

string = input("Please enter a word > ").lower()

print("This word is a palindrome" if string == string[::-1] else "This word is not a palindrome")

# Exercise 7 ##################################################

# Let’s say I give you a list saved in a variable:

# a = [1, 4, 9, 16, 25, 36, 49, 64, 81, 100].

# Write a line of Python that takes this list a and makes a new list that has only the even elements of this list in it.

a = [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
b = [num for num in a if num % 2 == 0]

# Exercise 8 ##################################################

# Make a two-player Rock-Paper-Scissors game.
# (Hint: Ask for player plays (using input), compare them, print out a message of congratulations to the winner,
# and ask if the players want to start a new game)

# Easiest initial approach (in my mind) is a while loop

playing = "y"

while playing == "y":
    player_1 = input("Player 1 selection:\n> ")
    player_2 = input("Player 2 selection:\n> ")

    if player_1 == player_2:
        playing = input("Draw!\nDo you with to play again? y/n")

    elif (player_1 == "rock" and player_2 == "scissors") or (player_1 == "paper" and player_2 == "rock") or (
            player_1 == "scissors" and player_2 == "paper"):
        playing = input("Player 1 wins!\nDo you with to play again? y/n")

    else:
        playing = input("Player 2 wins!\nDo you wish to play again? y/n")


# Although the "best" approach is probably a function (?)
def rps():

    player_1 = input("Player 1 selection:\n> ")
    player_2 = input("Player 2 selection:\n> ")

    # Also keep track of score now
    player_1_wins = 0
    player_2_wins = 0

    # There is probably a more elegant way of doing this
    # Separate function for determining winner or a list of some sort (?)
    if player_1 == player_2:
        playing = input("Draw!\nDo you wish to play again? y/n")

    elif (player_1 == "rock" and player_2 == "scissors") or (player_1 == "paper" and player_2 == "rock") or (
            player_1 == "scissors" and player_2 == "paper"):
        playing = input("Player 1 wins!\nDo you wish to play again? y/n")
        player_1_wins += 1

    else:
        playing = input("Player 2 wins!\nDo you wish to play again? y/n")
        player_2_wins += 1

    print(f"Current score:\nPlayer 1 : {player_1_wins} - {player_2_wins} : Player 2")

    rps() if playing == "y" else print(f"Final score:\nPlayer 1 : {player_1_wins} - {player_2_wins} : Player 2"); exit(1)


# Exercise 9 ##################################################

# Generate a random number between 1 and 9 (including 1 and 9). Ask the user to guess the number,
# then tell them whether they guessed too low, too high, or exactly right.

import random

num = int(input("Guess the random number between 0 and 9 (inclusive): > "))
ran_num = random.randint(0, 9)

if num == ran_num:
    print("You guessed it!")

elif num < ran_num:
    print("Too low!")

else:
    print("Too high!")

# Exercise 10 ##################################################

# This week’s exercise is going to be revisiting an old exercise (see Exercise 5),
# except require the solution in a different way. Take two lists, say for example these two:

# 	a = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]
# 	b = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]

# Write a program that returns a list that contains only the elements that are common between the lists (no duplicates).

# Already done sufficiently in the previous exercise
print(list(set([num for num in a if num in b])))

# Exercise 11 ##################################################

# Ask the user for a number and determine whether the number is prime or not.

num = int(input("Please choose a number: > "))

b = []
for i in range(1, num + 1):

    # Stop clause if more than 2 divisors are found: therefore not prime
    if len(b) >= 3:
        break

    if num % i == 0:
        b.append(i)
    else:
        pass

print("This number is prime" if len(b) == 2 else "This number is not prime")

# Exercise 12 ##################################################

# Write a program that takes a list of numbers (for example, a = [5, 10, 15, 20, 25]) and
# makes a new list of only the first and last elements of the given list.
# For practice, write this code inside a function.


def first_last(input_list):
    output_list = [input_list[0], input_list[-1]]
    print(output_list)


first_last([5, 10, 15, 20, 25])

# Exercise 13 ##################################################

# Write a program that asks the user how many Fibonnaci numbers to generate and then generates them.
# Take this opportunity to think about how you can use functions. Make sure to ask the user to enter
# the number of numbers in the sequence to generate.


def fib_seq():

    fib = [0, 1]
    num = int(input("How many Fibonnaci numbers to generate: > "))

    # If-statement ruins the "beauty"/simplicity of the code
    # but is necessary if user asks for only 1 or 2 Fib numbers.
    # Otherwise only required for loop at very end
    if num == 1:
        return print(fib[0])

    elif num == 2:
        return print(fib[0:2])

    else:

        for num in range(2, num):
            fib.append(fib[-2] + fib[-1])

        return print(fib)


fib_seq()

# Exercise 14 ##################################################

# Write a program (function!) that takes a list and returns a new list that contains all the
# elements of the first list minus all the duplicates.


def unique(input_list):

    output_list = []

    for element in input_list:
        if element not in output_list:
            output_list.append(element)
        else:
            pass

    return print(output_list)


# Exercise 15 ##################################################

# Write a program (using functions!) that asks the user for a long string containing multiple words.
# Print back to the user the same string, except with the words in backwards order.


def bckwds_str(string):
    str_list = ' '.join(string.split()[::-1])
    print(str_list)


bckwds_str("testing this out for the sake of it")

# Exercise 16 ##################################################

# Write a password generator in Python. Be creative with how you generate passwords -
# strong passwords have a mix of lowercase letters, uppercase letters, numbers, and symbols.
# The passwords should be random, generating a new password every time the user asks for a new password.
# Include your run-time code in a main method.

import random, string


def password_generator():
    password = []
    for i in range(3):
        password.append("".join(random.choices(string.ascii_letters + string.digits, k = 5)))

    return print('-'.join(password))


password_generator()

# Exercise 17 ##################################################

# Use the BeautifulSoup and requests Python packages to print out a list of all the article titles on the
# New York Times homepage.

import requests
from bs4 import BeautifulSoup

url = "https://www.nytimes.com"
r = requests.get(url)
r_html = r.text

soup = BeautifulSoup(r.text, features = "html.parser")

for story_heading in soup.find_all(class_="indicate-hover"):
    print(story_heading.contents[0].strip())

# This was in code provided, not sure if necessary anymore. Appears to do nothing...
# if story_heading.a in soup.find_all(class_="indicate-hover"):
#     print(story_heading.a.text.replace("\n", " ").strip())
# else:
#     print(story_heading.contents[0].strip())

# Exercise 18 ##################################################

# Create a program that will play the “cows and bulls” game with the user. The game works like this:
# Randomly generate a 4-digit number.Ask the user to guess a 4-digit number.
# For every digit that the user guessed correctly in the correct place, they have a “cow”.
# For every digit the user guessed correctly in the wrong place is a “bull.”
# Every time the user makes a guess, tell them how many “cows” and “bulls” they have.
# Once the user guesses the correct number, the game is over.
# Keep track of the number of guesses the user makes throughout the game and tell the user at the end.

import random

rand_num = list(str(random.randint(1000, 9999)))
# print(rand_num)
cow_bull = [False, False, False, False]
tries = 1

while cow_bull.count(True) < 4:
    guess_num = list(input("Guess a 4 digit number: > "))
    cow_bull = [i == j for i, j in zip(rand_num, guess_num)]
    print(f"You have {cow_bull.count(False)} cows, {cow_bull.count(True)} bulls.")
    tries += 1

    print(f"Congratulations! You guessed the number in {tries - 1} tries") if cow_bull.count(True) == 4 else None

# Again, turn this while loop into a function


def play_cow_bull(tries = 1):

    global rand_num

    # This was the clearest way for me to have everything assigned within the function
    if tries == 1:
        rand_num = list(str(random.randint(1000, 9999)))
        # print(rand_num)
    else:
        pass

    guess_num = list(input("Guess a 4 digit number: > "))
    cow_bull = [i == j for i, j in zip(rand_num, guess_num)]
    print(f"You have {cow_bull.count(False)} cows, {cow_bull.count(True)} bulls.")
    tries += 1

    # Call function again if incorrect, but update tries argument so our random number isn't overwritten
    print(f"Congratulations! You guessed the number in {tries - 1} tries") if cow_bull.count(True) == 4 else play_cow_bull(tries)


play_cow_bull()

# Exercise 19 ##################################################

# Using the requests and BeautifulSoup Python libraries, print to the screen the text of the article on this website:
# http://www.vanityfair.com/society/2014/06/monica-lewinsky-humiliation-culture.
# The article is long, so it is split up between 4 pages. Your task is to print out the text to the screen so that you
# can read the full article without having to click any buttons.

import requests
from bs4 import BeautifulSoup

url = "http://www.vanityfair.com/society/2014/06/monica-lewinsky-humiliation-culture"
r = requests.get(url)
r_html = r.text

soup = BeautifulSoup(r.text, features = "html.parser")

for text_body in soup.find_all(class_="paywall"):
    print(text_body.contents[0].strip())

# Websites were probably simpler when this was originally tasked. This is not good. But good enough.
# Provided solution no longer works, which is validation of my above comment.

# all_p_cn_text_body = soup.select("div.parbase.cn_text > div.body > p")
# for elem in all_p_cn_text_body[7:]:
# print(elem.text)

# Exercise 20 ##################################################

# Write a function that takes an ordered list of numbers and another number.
# The function decides whether or not the given number is inside the list and returns an appropriate boolean.


def list_search(ordered_list, num):
    print(num in ordered_list)


list_search([1, 2, 3, 4, 5], 5)
list_search([1, 2, 3, 4, 5], 10)

# Exercise 21 ##################################################

# Take the code from the How To Decode A Website exercise and
# instead of printing the results to a screen, write the results to a txt file.
# In your code, just make up a name for the file you are saving to.

import requests
from bs4 import BeautifulSoup

url = "https://www.nytimes.com"
r = requests.get(url)
r_html = r.text

soup = BeautifulSoup(r.text, features = "html.parser")

with open("nytimes.txt", "w") as open_file:
    for story_heading in soup.find_all(class_ = "indicate-hover"):
        open_file.write(story_heading.contents[0].strip() + "\n")


# Exercise 22 ##################################################

# Given a .txt file that has a list of a bunch of names, count how many of each name there are in the file, and
# print out the results to the screen. I have a .txt file for you, if you want to use it!
# "https://www.practicepython.org/assets/nameslist.txt"

from collections import Counter

data = open("names.txt").read().splitlines()

print(Counter(data))

# Exercise 23 ##################################################

# Given two .txt files that have lists of numbers in them, find the numbers that are overlapping.
# One .txt file has a list of all prime numbers under 1000, the other .txt file has a list of happy numbers up to 1000.
# https://www.practicepython.org/assets/primenumbers.txt
# https://www.practicepython.org/assets/happynumbers.txt

prime_nums = open("prime_nums.txt").read().splitlines()
happy_nums = open("happy_nums.txt").read().splitlines()

prime_happy_nums = [num for num in prime_nums if num in happy_nums]

# Exercise 24 ##################################################

# This exercise is Part 1 of 4 of the Tic Tac Toe exercise series.
# Time for some fake graphics! Let’s say we want to draw game boards that look like this:

#  --- --- ---
# |   |   |   |
#  --- --- ---
# |   |   |   |
#  --- --- ---
# |   |   |   |
#  --- --- ---

# This one is 3x3 (like in tic tac toe). Obviously, they come in many other sizes (e.g. 8x8 for chess).
# Ask the user what size game board they want to draw, and draw it for them using Python’s print statement.

def draw_board():
    width = int(input("Width: > "))
    height = int(input("Height: > "))

    for i in range(height):
        print(" ---" * width + " ")
        print("|   " * width + "|")

        if i == height - 1:
            print(" ---" * width + " ")
        else:
            continue


draw_board()

# Exercise 25 ##################################################

# In a previous exercise, we’ve written a program that “knows” a number and asks a user to guess it.
# This time, we’re going to do exactly the opposite. You, the user, will have in your head a number between 0 and 100.

# The program will guess a number, and you, the user, will say whether it is too high, too low, or your number.
# At the end of this exchange, your program should print out how many guesses it took to get your number.

# As the writer of this program, you will have to choose how your program will strategically guess.
# A naive strategy can be to simply start the guessing at 1, and keep going (2, 3, 4, etc.) until you hit the number.

# But that’s not an optimal guessing strategy. An alternate strategy might be to guess 50 (in the middle of the range),
# ease by 1 as needed. After you’ve written the program, try to find the optimal strategy!


def num_guess(x = round(sum([0, 100]) / 2), tries = 1):

    global num_range

    if tries == 1:
        num_range = [0, 100]
    else:
        pass

    guess = input(f"The computer guesses {x}. Is the answer correct / higher / lower?: > ")

    if guess == "correct":
        return print(f"Congrats! The computer guessed it in {tries} tries")
    elif guess == "lower":
        print("Guessed too high! Calibrating...")
        num_range[1] = x - 1
    else:
        print("Guessed too low! Calibrating...")
        num_range[0] = x + 1

    x = round(sum(num_range) / 2)
    tries += 1
    num_guess(x, tries)


num_guess()

# Exercise 26 ##################################################

# This exercise is Part 2 of 4 of the Tic Tac Toe exercise series.
# As you may have guessed, we are trying to build up to a full tic-tac-toe board.
# However, this is significantly more than half an hour of coding, so we’re doing it in pieces.

# Today, we will simply focus on checking whether someone has WON a game of Tic Tac Toe,
# not worrying about how the moves were made. If a game of Tic Tac Toe is represented as a list of lists, like so:
# game =  [[1, 2, 0], [2, 1, 0], [2, 1, 1]]
# where a 0 means an empty square, a 1 means that player 1 put their token in that space,
# and a 2 means that player 2 put their token in that space.

# Your task this week: given a 3 by 3 list of lists that represents a Tic Tac Toe game board,
# tell me whether anyone has won, and tell me which player won, if any.
# A Tic Tac Toe win is 3 in a row - either in a row, a column, or a diagonal.
# Don’t worry about the case where TWO people have won - assume that in every board there will only be one winner.


def game_winner(board):

    # Horizontal win
    for i in range(3):
        if len(set([num for num in board[i]])) == 1 and [num for num in board[i]][0] != 0:
            winner = [num for num in board[i]][0]
            return print(f"Player {winner} wins!")
        else:
            continue

    # Vertical win
    for i in range(3):
        if len(set([num[i] for num in board])) == 1 and [num[i] for num in board][0] != 0:
            winner = [num[i] for num in board][0]
            return print(f"Player {winner} wins!")
        else:
            continue

    # Diagonal win
    if len(set([row[i] for i, row in enumerate(board)])) == 1 and [row[i] for i, row in enumerate(board)][0] != 0:
        winner = [row[i] for i, row in enumerate(board)][0]
        return print(f"Player {winner} wins!")
    elif len(set([row[- i - 1] for i, row in enumerate(board)])) == 1 and [row[- i - 1] for i, row in enumerate(board)][0] != 0:
        winner = [row[- i - 1] for i, row in enumerate(board)][0]
        return print(f"Player {winner} wins!")
    else:
        return print("No winner. Game is a draw.")


test_games = {
    "game": [[1, 2, 0], [2, 1, 0], [2, 1, 1]],
    "winner_is_2": [[2, 2, 0], [2, 1, 0], [2, 1, 1]],
    "winner_is_1": [[1, 2, 0], [2, 1, 0], [2, 1, 1]],
    "winner_is_also_1": [[0, 1, 0], [2, 1, 0], [2, 1, 1]],
    "no_winner": [[1, 2, 0], [2, 1, 0], [2, 1, 2]],
    "also_no_winner": [[1, 2, 0], [2, 1, 0], [2, 1, 0]]
}

for game in test_games:
    print(game)
    game_winner(test_games[game])
    print("*"*10)

# Exercise 27 ##################################################

# This exercise is Part 3 of 4 of the Tic Tac Toe exercise series.
# In a previous exercise we explored the idea of using a list of lists as a “data structure”
# to store information about a tic tac toe game. In a tic tac toe game, the “game server” needs to know where
# the Xs and Os are in the board, to know whether player 1 or player 2 (or whoever is X and O won).

# There has also been an exercise about drawing the actual tic tac toe gameboard using text characters.
# The next logical step is to deal with handling user input. When a player (say player 1, who is X)
# wants to place an X on the screen, they can’t just click on a terminal. So we are going to approximate this clicking
# simply by asking the user for a coordinate of where they want to place their piece.

# As a reminder, our tic tac toe game is really a list of lists. The game starts out with an empty game board like this:

# game = [[0, 0, 0],
# [0, 0, 0],
# [0, 0, 0]]

# The computer asks Player 1 (X) what their move is, and say they type 1,3. Then the game would print out

# game = [[0, 0, X],
# [0, 0, 0],
# [0, 0, 0]]

# And ask Player 2 for their move, printing an O in that place.

# Things to note:

# For this exercise, assume that player 1 (the first player to move) will always be X and
# player 2 (the second player) will always be O.

# Notice how in the example I gave coordinates for where I want to move starting from (1, 1) instead of (0, 0).
# To people who don’t program, starting to count at 0 is a strange concept, so it is better for the user experience if
# the row counts and column counts start at 1. This is not required, but whichever way you choose to implement this,
# it should be explained to the player.

# Ask the user to enter coordinates in the form “row,col” - a number, then a comma, then a number.
# Then you can use your Python skills to figure out which row and column they want their piece to be in.
# Don’t worry about checking whether someone won the game, but if a player tries to put a piece in a game position
# where there already is another piece, do not allow the piece to go there.

import re

game = [["·", "·", "·"], ["·", "·", "·"], ["·", "·", "·"]]

while any("·" in check for check in game):

    player_1 = re.sub("[^0-9]", "", input("Player 1, place your X: > "))

    while int(player_1[0]) > 3 or int(player_1[1]) > 3:
        print("Invalid coordinates. Please choose another.")
        player_1 = re.sub("[^0-9]", "", input("Player 1, place your X: > "))

    while game[int(player_1[1]) - 1][int(player_1[0]) - 1] != "·":
        print("Place has already been taken. Please choose another.")
        player_1 = re.sub("[^0-9]", "", input("Player 1, place your X: > "))

    game[int(player_1[1]) - 1][int(player_1[0]) - 1] = "X"
    for x, y, z in zip(*game):
        print(x, y, z)

    # Supposed to be purpose of while loop
    if not any("·" in check for check in game): break

    # Repetitive. Look to make players (or game as a whole) one generic function
    player_2 = re.sub("[^0-9]", "", input("Player 2, place your O: > "))

    while int(player_2[0]) > 3 or int(player_2[1]) > 3:
        print("Invalid coordinates")
        player_2 = re.sub("[^0-9]", "", input("Player 2, place your O: > "))

    while game[int(player_2[1]) - 1][int(player_2[0]) - 1] != "·":
        print("Place has already been taken. Please choose another.")
        player_2 = re.sub("[^0-9]", "", input("Player 2, place your O: > "))

    game[int(player_2[1]) - 1][int(player_2[0]) - 1] = "O"
    for x, y, z in zip(*game):
        print(x, y, z)

# We will leave for now, and wait to put everything into functions when we are tasked with putting everything together

# Exercise 28 ##################################################

# Implement a function that takes as input three variables, and returns the largest of the three.
# Do this without using the Python max() function!
# The goal of this exercise is to think about some internals that Python normally takes care of for us.
# All you need is some variables and if statements!


def my_max(arg1, arg2, arg3):
    # 4 cases
    if arg1 > arg2 > arg3:
        return arg1
    elif arg1 < arg2 < arg3:
        return arg3
    elif arg1 < arg2 > arg3:
        return arg2
    else: # i.e. arg1 > agr2 < arg3 (do we even need this one?)
        if arg1 > arg3:
            return arg1
        else:
            return arg3

# Much cleaner copied code:
# def maxfunction(a,b,c):
# 	if (a > b) and (a > c):
# 	    print 'Max value is :',a
#         elif (b > a) and (b > c):
#             print 'Max value is :',b
#         elif (c > a) and (c > b):
#             print 'Max value is :',c

# Exercise 29 ##################################################

# The next step is to put all these three components together to make a two-player Tic Tac Toe game!
# Your challenge in this exercise is to use the functions from those previous exercises all together in the same program
# to make a two-player game that you can play with a friend. There are a lot of choices you will have to make when
# completing this exercise, so you can go as far or as little as you want with it.

# Here are a few things to keep in mind:

# You should keep track of who won - if there is a winner, show a congratulatory message on the screen.
# If there are no more moves left, don’t ask for the next player’s move!
# As a bonus, you can ask the players if they want to play again and keep a running tally of who won more.

import re


# Undoubtedly this code code be written in a much simpler - and therefore more elegant - way, but it works...
# Easiest way I could get game to loop after a game
def play_again():

    global player_1_score, player_2_score

    playing = input("Play again? y/n: > ")
    if playing == "y":
        print(f"Current score\nPlayer 1 : {player_1_score} - {player_2_score} : Player 2")
        # We don't need to count the rounds, just need round_count != 1 so it doesn't overwrite scores
        tic_tac_toe(move = 1, round_count = 2)
    else:
        print(f"Final score\nPlayer 1 : {player_1_score} - {player_2_score} : Player 2")
        exit(1)


def game_winner(board):

    global game, player_1_score, player_2_score

    # Plotting vs how we interpret coords means things are transposed
    # So really horizontal is vertical and vice versa, but it doesn't impact outcome (or even type of win, the board
    # is merely flipped)

    # Horizontal win
    for i in range(3):
        if len(set([num for num in board[i]])) == 1 and "·" not in [num for num in board[i]]:
            if [num for num in board[i]][0] == "X":
                print("Player 1 wins!")
                player_1_score += 1
            else:
                print("Player 2 wins!")
                player_2_score += 1

            play_again()

        else:
            pass

    # Vertical win
    for i in range(3):
        if len(set([num[i] for num in board])) == 1 and "·" not in [num[i] for num in board]:
            if [num[i] for num in board][0] == "X":
                print("Player 1 wins!")
                player_1_score += 1
            else:
                print("Player 2 wins!")
                player_2_score += 1

            play_again()

        else:
            pass

    # Diagonal win
    if len(set([row[i] for i, row in enumerate(board)])) == 1 and "·" not in [row[i] for i, row in enumerate(board)]:
        if [row[i] for i, row in enumerate(board)][0] == "X":
            print("Player 1 wins!")
            player_1_score += 1
        else:
            print("Player 2 wins!")
            player_2_score += 1

        play_again()

    # "Opposite" diagonal win
    elif len(set([row[- i - 1] for i, row in enumerate(board)])) == 1 and "·" not in [row[- i - 1] for i, row in enumerate(board)]:
        if [row[- i - 1] for i, row in enumerate(board)][0] == "X":
            print("Player 1 wins!")
            player_1_score += 1
        else:
            print("Player 2 wins!")
            player_2_score += 1

        play_again()

    else:
        pass

    # Draw
    if any("·" in sublist for sublist in board):
        pass
    else:
        print("Draw!")
        play_again()


# Create player function (while loop was repetitive which signifies it can be improved)
def tic_tac_toe_player(player = None):

    global game

    coords = re.sub("[^0-9]", "", input(f"Player {player}, place your {'X' if player == 1 else 'O'}: > "))

    if int(coords[0]) > 3 or int(coords[1]) > 3:
        print("Invalid coordinates. Please choose another.")
        tic_tac_toe_player(player)
    elif game[int(coords[1]) - 1][int(coords[0]) - 1] != "·":
        print("Place has already been taken. Please choose another.")
        tic_tac_toe_player(player)
    else:
        game[int(coords[1]) - 1][int(coords[0]) - 1] = "X" if player == 1 else "O"
        for x, y, z in zip(*game):
            print(x, y, z)


# Now, we will convert our previous while-loop into into a function
# Much like with the "tries" argument in previous functions, I'll use round to initially define the starting
# game, and then ensure it's not overwritten. I don't like the fact that they're arguments however. What's a better way?
def tic_tac_toe(move = 1, round_count = 1):

    global game, player_1_score, player_2_score

    if round_count == 1:
        player_1_score = 0
        player_2_score = 0
    else:
        pass

    if move == 1:
        game = [["·", "·", "·"], ["·", "·", "·"], ["·", "·", "·"]]
    else:
        pass

    tic_tac_toe_player(1)
    game_winner(game)

    tic_tac_toe_player(2)
    game_winner(game)

    move +=1

    tic_tac_toe(move, round_count)


tic_tac_toe()

# Exercise 30 ##################################################

# This exercise is Part 1 of 3 of the Hangman exercise series.
# The task is to write a function that picks a random word from a list of words from the SOWPODS dictionary.
# Download this file and save it in the same directory as your Python code. This file is Peter Norvig’s compilation
# of the dictionary of words used in professional Scrabble tournaments. Each line in the file contains a single word.

# http://norvig.com/ngrams/sowpods.txt

import requests

url = "http://norvig.com/ngrams/sowpods.txt"
data = requests.get(url)
open('sowpods.txt', 'wb').write(data.content)

# Alternative method
# import urllib.request
# url = "http://norvig.com/ngrams/sowpods.txt"
# data = urllib.request.urlopen(url).read()

data = open("sowpods.txt").read().splitlines()

import random

print(random.choice(data))

# Exercise 31 ##################################################

# This exercise is Part 2 of 3 of the Hangman exercise series.
# In the game of Hangman, a clue word is given by the program that the player has to guess,
# letter by letter. The player guesses one letter at a time until the entire word has been guessed.
# (In the actual game, the player can only guess 6 letters incorrectly before losing).

# For this exercise, write the logic that asks a player to guess a letter and displays letters in the clue word
# that were guessed correctly. For now, let the player guess an infinite number of times until they get the entire word.
# As a bonus, keep track of the letters the player guessed and display a different message if the player tries to
# guess that letter again. Remember to stop the game when all the letters have been guessed correctly!
# Don’t worry about choosing a word randomly or keeping track of the number of guesses the player has remaining -
# we will deal with those in a future exercise.

import random

data = open("sowpods.txt").read().splitlines()
word = list(random.choice(data).lower())
board = list("_" * len(word))
guesses = []
tries = 1


def hangman():
    global tries
    guess = input("Choose a letter: > ")
    if guess in guesses:
        print("Letter already guessed")
        hangman()

    fill = [i for i in range(len(word)) if word[i] == guess]

    for i in fill:
        board[i] = guess

    guesses.append(guess)
    print(" ".join(board))
    print("\nLetters guessed: " + ", ".join(guesses))
    print("*" * 10)

    if "_" not in board:
        print(f"Congratulations, you have guessed the word in {tries} tries!")
    else:
        tries += 1
        hangman()


hangman()

# NOTE: When we limit to only 6 guesses, when they get a correct letter we don't add to "tries"
# Otherwise they'll only be able to ever guess < 7 letter words (6 letter words only with "perfect play")

# Exercise 32 ##################################################

# This exercise is Part 3 of 3 of the Hangman exercise series.

# In this exercise, we will finish building Hangman. In the game of Hangman, the player only has 6 incorrect guesses
# (head, body, 2 legs, and 2 arms) before they lose the game.

# In Part 1, we loaded a random word list and picked a word from it. In Part 2, we wrote the logic for
# guessing the letter and displaying that information to the user. In this exercise, we have to put it all together
# and add logic for handling guesses.

# Copy your code from Parts 1 and 2 into a new file as a starting point. Now add the following features:
# Only let the user guess 6 times, and tell the user how many guesses they have left.
# Keep track of the letters the user guessed. If the user guesses a letter they already guessed, don’t penalize them -
# let them guess again.

import random

data = open("sowpods.txt").read().splitlines()


def play_again():
    playing = input("Do you want to play again? y/n: > ")
    if playing == "y":
        hangman(tries = 0)
    else:
        exit(1)


def hangman(tries = 0):

    global word, board, guesses

    if tries == 0:
        word = list(random.choice(data).lower())
        board = list("_" * len(word))
        guesses = []
    else:
        pass

    guess = input("Choose a letter: > ").lower()

    while (guess in guesses) or len(guess) > 1 or not guess.isalpha():
        guess = input("Letter already guessed (or invalid guess). Choose a letter: > ")

    fill = [i for i in range(len(word)) if word[i] == guess]

    # Tries only penalised when they guess incorrectly
    if len(fill) == 0:
        tries += 1
    else:
        pass

    for i in fill:
        board[i] = guess

    guesses.append(guess)
    print(" ".join(board))
    print("\nLetters guessed: " + ", ".join(guesses))
    print("*" * 10)

    if "_" not in board:
        print(f"Congratulations, you have guessed the word in {tries} tries!")
        play_again()
    elif tries == 6:
        print(f"Uh oh, you have used up all of your {tries} tries!\nThe word was: {''.join(word)}")
        play_again()
    else:
        print(f"You have {6 - tries} tries remaining")
        hangman(tries)


hangman()

# Exercise 33 ##################################################

# This exercise is Part 1 of 4 of the birthday data exercise series.
# We will keep track of when our friend’s birthdays are, and be able to find that information based on their name.
# Create a dictionary of names and birthdays. When you run your program it should ask the user to enter a name,
# and return the birthday of that person back to them.

import datetime

birthdays = {
    "Henry": datetime.datetime(1996, 1, 20),
    "Meredith": datetime.datetime(1966, 1, 15),
    "Theo": datetime.datetime(2005, 9, 22),
    "Oliver": datetime.datetime(1999, 9, 26),
    "Anwar": datetime.datetime(1966, 4, 5),
    "Alison": datetime.datetime(1996, 6, 19),
    "Jessi": datetime.datetime(1996, 6, 19),
}

nl = ", \n"
print(f"Welcome to the birthday dictionary. We know the birthdays of: {nl}{nl.join(birthdays.keys())}")
b_day = input("Who's birthday do you want to look up? > ")

print(f"{b_day}'s birthday is {birthdays[b_day].strftime('%B %d %Y')}")

# Exercise 34 ##################################################

# This exercise is Part 2 of 4 of the birthday data exercise series.
# In the previous exercise we created a dictionary of famous scientists’ birthdays.
# In this exercise, modify your program from Part 1 to load the birthday dictionary from a JSON file on disk,
# rather than having the dictionary defined in the program.

# Bonus: Ask the user for another scientist’s name and birthday to add to the dictionary,
# and update the JSON file you have on disk with the scientist’s name. If you run the program multiple times
# and keep adding new names, your JSON file should keep getting bigger and bigger.

import json

# TypeError: Object of type datetime is not JSON serializable

birthdays = {
    "Henry": "1996-01-20",
    "Meredith": "1966-01-15",
    "Theo": "2005-09-22",
    "Oliver": "1999-09-26",
    "Anwar": "1966-04-05",
    "Alison": "1996-06-19",
    "Jessi": "1996-06-19",
}

with open("birthdays.json", "w") as f:
    json.dump(birthdays, f)

with open("birthdays.json", "r") as f:
    birthdays = json.load(f)

birthdays.update({
  input("Add person to the list: > "): input("What is their birthday?: > ")
})

with open("birthdays.json", "w") as f:
    json.dump(birthdays, f)

# Exercise 35 ##################################################

# This exercise is Part 3 of 4 of the birthday data exercise series.

# In the previous exercise we saved information about famous scientists’ names and birthdays to disk.
# In this exercise, load that JSON file from disk, extract the months of all the birthdays,
# and count how many scientists have a birthday in each month.

import json
import datetime
from collections import Counter

with open("birthdays.json", "r") as f:
    birthdays = json.load(f)

bday_months = []
for birthday in list(birthdays.values()):
    bday_months.append(datetime.datetime(1, int(birthday[5:7]), 1).strftime("%B"))

print(Counter(bday_months))

# Exercise 36 ##################################################

# This exercise is Part 4 of 4 of the birthday data exercise series.
# In the previous exercise we counted how many birthdays there are in each month in our dictionary of birthdays.
# In this exercise, use the bokeh Python library to plot a histogram of which months the scientists have birthdays in!
# Parse out the months and draw your histogram.

from bokeh.plotting import figure, show, output_file
import json
import datetime
from collections import Counter

with open("birthdays.json", "r") as f:
    birthdays = json.load(f)

bday_months = []
for birthday in list(birthdays.values()):
    bday_months.append(datetime.datetime(1, int(birthday[5:7]), 1).strftime("%B"))

plos_vals = Counter(bday_months)

output_file("month_plot.html")

x_categories = []
for i in range(1, 13):
    x_categories.append(datetime.datetime(1, i, 1).strftime("%B"))

x = list(plos_vals.keys())
y = list(plos_vals.values())

p = figure(x_range = x_categories)
p.vbar(x = x, top = y, width = 0.5)

show(p)

# Exercise 37 ##################################################

# One area of confusion for new coders is the concept of functions.
# We will be stretching our functions muscle by refactoring an existing code snippet into using functions.
# Here is the code snippet to refactor:

# print(" --- --- ---")
# print("|   |   |   |")
# print(" --- --- ---")
# print("|   |   |   |")
# print(" --- --- ---")
# print("|   |   |   |")
# print(" --- --- ---")

# Already done sufficiently in the original exercise:

def draw_board():
    width = int(input("Width: > "))
    height = int(input("Height: > "))

    for i in range(height):
        print(" ---" * width + " ")
        print("|   " * width + "|")

        if i == height - 1:
            print(" ---" * width + " ")
        else:
            continue


draw_board()

# Exercise 38 ##################################################

# Implement the same exercise as Exercise 1
# Print out a message addressed to them that tells them the year that they will turn 100 years old, except use f-strings
# instead of the + operator to print the resulting output message.

# Already done sufficiently in the original exercise:

name = input("Please enter your name > ")
age = input("Next, please enter your age > ")
print(f"Hello {name}, you will turn 100 in the year {100 - int(age) + 2022}")

# Exercise 39 ##################################################

# Implement the same exercise as Exercise 1
# Except don’t explicitly write out the year. Use the built-in Python datetime library to make the code you write work
# during every year, not just the one we are currently in.

import datetime

name = input("Please enter your name > ")
age = input("Next, please enter your age > ")
print(f"Hello {name}, you will turn 100 in the year {100 - int(age) + datetime.date.today().year}")

# Exercise 40 ##################################################

# Given this solution to Exercise 9, modify it to have one level of user feedback:
# if the user does not enter a number between 1 and 9, tell them.
# Don’t count this guess against the user when counting the number of guesses they used.

# import random
#
# number = random.randint(1, 9)
# number_of_guesses = 0
# while True:
# 	guess = int(input("Guess a number between 1 and 9: "))
# 	number_of_guesses += 1
# 	if guess == number:
# 		break
# print(f"You needed {number_of_guesses} guesses to guess the number {number}")

import random

number = random.randint(1, 9)
number_of_guesses = 0
while True:
    guess = int(input("Guess a number between 1 and 9: "))

    if guess not in range(1, 10):
        print("Guess is not a number between 1 and 9. Try again!")
        continue

    number_of_guesses += 1
    if guess == number:
        break
print(f"You needed {number_of_guesses} guesses to guess the number {number}")