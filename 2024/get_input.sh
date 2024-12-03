#!/bin/bash

curl --cookie "session=$1" https://adventofcode.com/2024/day/"$2"/input -o "input/d$2"
