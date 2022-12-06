package main

import (
	"aoc2022/helpers"
	"fmt"
	"strings"
)

func findNonRepeating(chars []string, length int) int {
	windows := helpers.Windowed(chars, length)

	var count int
	for i, w := range windows {
		s := helpers.NewSet(w)
		size := len(s)
		if size == length {
			count = length + i
			break
		}
	}

	return count
}

func part1(file string) int {
	input := helpers.ReadFile(file)
	chars := strings.Split(input, "")

	return findNonRepeating(chars, 4)
}

func part2(file string) int {
	input := helpers.ReadFile(file)
	chars := strings.Split(input, "")

	return findNonRepeating(chars, 14)
}

func main() {
	fmt.Println(part1("input"))
	fmt.Println(part2("input"))
}
