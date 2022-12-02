package main

import (
	"aoc2022/helpers"
	"fmt"
	"strings"
)

type Move int

const (
	Rock Move = iota
	Paper
	Scissor
)

func (this Move) fight(other Move) int {
	if this == other {
		return 3 + (int(this + 1))
	}
	if (int(this)+1)%3 == int(other) {
		return 0 + int(this+1)
	} else {
		return 6 + int(this+1)
	}
}

type Round struct {
	elf  Move
	self Move
}

func (this Round) eval() int {
	return this.self.fight(this.elf)
}

func strToMove(m string) Move {
	switch m {
	case "A", "X":
		return Rock
	case "B", "Y":
		return Paper
	default:
		// "C", "Z"
		return Scissor
	}
}

func lineToRound(l string) Round {
	parts := strings.Split(l, " ")
	return Round{
		elf:  strToMove(parts[0]),
		self: strToMove(parts[1]),
	}
}

func play(lines []string) int {
	var res int
	for _, line := range lines {
		if line == "" {
			continue
		}
		round := lineToRound(line)
		res += round.eval()
	}

	return res
}

func part1() int {
	lines := helpers.ReadLines("input")
	return play(lines)
}

func main() {
	fmt.Println(part1())
}
