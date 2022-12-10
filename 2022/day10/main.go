package main

import (
	"aoc2022/helpers"
	"fmt"
	"strings"
)

func part1(lines []string) int {
	x, cycle, sum := 1, 0, 0
	for _, line := range lines {
		p := strings.Split(line, " ")
		t := p[0]
		switch t {
		case "addx":
			cycle, sum = tick(x, cycle, sum)
			cycle, sum = tick(x, cycle, sum)
			x += helpers.ToInt(p[1])
		case "noop":
			cycle, sum = tick(x, cycle, sum)
		}
	}

	return sum
}

func tick(x, cycle, sum int) (int, int) {
	drawPosition := cycle % 40
	if drawPosition >= x-1 && drawPosition <= x+1 {
		fmt.Print("#")
	} else {
		fmt.Print(".")
	}
	if drawPosition == 39 {
		fmt.Println()
	}
	cycle += 1
	if (cycle+20)%40 == 0 {
		sum += cycle * x
	}

	return cycle, sum
}

func main() {
	lines := helpers.ReadLines("input")
	fmt.Println(part1(lines))
}
