#!/bin/bash

curl -b session="$2" https://adventofcode.com/2024/day/"$1"/input -o "input/d$1"
