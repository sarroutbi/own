#!/usr/bin/env python
#
# Copyright (c) 2017, Sergio Arroutbi Braojos <sarroutbi (at) yahoo.es>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
"""
Program to test Monty Hall paradigm
Usage:
${0} [-c: user changes door] [-d: number of doors, 3 by default] [-i: iterations, 10000 by default]
"""
import argparse
import random
import os
import sys
from enum import Enum

DEFAULT_DOORS_AMOUNT=3
DEFAULT_CHANGE=False
DEFAULT_ITERATIONS=10000

class DoorContent(Enum):
    """
    Different types of door content
    """
    GOAT = 1
    CAR  = 2
    NONE = 3

class Result:
    """
    Representation of a result

    Attributes:
    - selected (door selected by user)
    - content (goat/cat)
    """
    def __init__(self):
        self.win = 0
        self.loose = 0
    def __str__(self):
        return str("-----------------------------" + "\n"
                   "Wins:"   + str(self.win) + " " +
                   "Looses:" + str(self.loose) + "\n" +
                   "-----------------------------")
    def add_win(self):
        """
        Add win to the current results
        """
        self.win += 1
    def add_loose(self):
        """
        Add loose to the current results
        """
        self.loose += 1

class Door:
    """
    Representation of a door

    Attributes:
    - selected (door selected by user)
    - content (goat/cat)
    - opened
    """
    def __init__(self, content_type = DoorContent.NONE):
        self.content = content_type
        self.selected = False
        self.opened = False
    def is_winning_door(self):
        """
        Function to check if the door is a winning door
        """
        return self.selected and DoorContent.CAR == self.content
    def open(self):
        """
        Function to set a door as opened
        """
        self.opened = True
    def __str__(self):
        """
        Function to print door as string
        """
        return f'{"G" if self.content == DoorContent.GOAT else "C"}\
        { "o" if self.opened else "c"}{"s" if self.selected else "n"}'

def print_doors(doors):
    """
    Print doors in its current state
    """
    for door in doors:
        print(door, end="")
    print()

def user_wins(doors):
    """
    Check if user wins (selected door has the car)
    """
    for door in doors:
        if door.is_winning_door():
            return True
    return False

def create_doors(args):
    """
    Create the doors with its content (one car, rest goats)
    """
    doors = []
    car_position = random.randint(0, args.d-1)
    for udoor in range(0, args.d):
        if car_position == udoor:
            door = Door(DoorContent.CAR)
        else:
            door = Door(DoorContent.GOAT)
        doors.append(door)
    return doors

def open_goat_door(doors):
    """
    Function that opens a door containing a goat from door array
    """
    for door in doors:
        if door.content is DoorContent.GOAT and door.selected is False \
           and door.opened is False:
            door.open()
            return doors
    return doors

def user_selects_door(doors):
    """
    Function that selects a door for the user randomly
    """
    user_selection = random.randint(0, len(doors)-1)
    doors[user_selection].selected = True

def change_user_selection(doors):
    """
    Function that changes user's selected door
    """
    user_made_selection = False
    for door_number, door in enumerate(doors):
        if door.selected:
            previous_selected = door_number
    while not user_made_selection:
        selection = random.randint(0, len(doors)-1)
        for door_number, door in enumerate(doors):
            if door_number == selection and not door.opened \
               and not door.selected:
                door.selected = True
                user_made_selection = True
                doors[previous_selected].selected = False
        if user_made_selection:
            return

def parse_args():
    """
    Function that parses incoming arguments
    """
    parser = argparse.ArgumentParser(os.path.basename(sys.argv[0]) + \
                                     ' program tests Monty Hall paradigm')
    parser.add_argument('-d', help='number of doors',
                        type=int, default=DEFAULT_DOORS_AMOUNT)
    parser.add_argument('-i', help='number of iterations (times to play)',
                        type=int, default=DEFAULT_ITERATIONS)
    parser.add_argument('-c', help='set for user to change door after open goat one',
                        action='store_true', default=DEFAULT_CHANGE)
    return parser.parse_args()

def calculate_results(args, doors, results):
    """
    Main function to calculate results of the game
    """
    open_goat_door(doors)
    if args.c:
        change_user_selection(doors)
    if user_wins(doors):
        results.add_win()
    else:
        results.add_loose()

def iterations(args):
    """
    Function that plays a number of times
    """
    result = Result()

    # For each iteration (number of iteration is a parameter)
    for _ in range(0, args.i):
        # Create the doors (number of doors is other parameter)
        doors = create_doors(args)
        # User selects door randomly, and changes door or not (door change is a parameter)
        user_selects_door(doors)
        # Calculate and store result
        calculate_results(args, doors, result)
        # end iterations
    print(result)

def main():
    """
    Main function
    """
    iterations(parse_args())

if __name__ == "__main__":
    main()
