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

func (this Move) String() string {
	switch this {
	case Rock:
		return "Rock"
	case Paper:
		return "Paper"
	default: /* Scissor */
		return "Scissor"
	}
}

func (this Move) fight(other Move) int {
	var res int
	if this == other {
		res = 3 + this.value()
	} else if (int(this)+1)%3 == int(other) {
		res = 0 + this.value()
	} else {
		res = 6 + this.value()
	}

	return res
}

func (this Move) value() int {
	return int(this) + 1
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
	default: /* "C", "Z" */
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

type Result int

const (
	Lose Result = iota
	Draw
	Win
)

func (this Result) String() string {
	switch this {
	case Lose:
		return "Lose"
	case Draw:
		return "Draw"
	default: /* Win */
		return "Win"
	}
}

func strToResult(s string) Result {
	switch s {
	case "X":
		return Lose
	case "Y":
		return Draw
	default: /* Z */
		return Win
	}
}

func (this Move) predict(result Result) int {
	var res int
	if result == Draw {
		res = 3 + this.value()
	} else if result == Win {
		res = 6 + Move((int(this)+1)%3).value()
	} else {
		res = 0 + Move((int(this)+2)%3).value()
	}

	return res
}

func predict(lines []string) int {
	var sum int
	for _, line := range lines {
		if line == "" {
			continue
		}
		parts := strings.Split(line, " ")
		move := strToMove(parts[0])
		res := strToResult(parts[1])
		sum += move.predict(res)
	}

	return sum
}

func part2() int {
	lines := helpers.ReadLines("input")
	return predict(lines)
}

func main() {
	// fmt.Println(part1())
	fmt.Println(part2())
}
