package main

import (
	"aoc2022/helpers"
	"fmt"
	"strings"
)

type Move struct {
	direction string
	steps     int
}

func parseMove(lines []string) (out []Move) {
	for _, line := range lines {
		parts := strings.Split(line, " ")
		out = append(out, Move{
			direction: parts[0],
			steps:     helpers.ToInt(parts[1]),
		})
	}

	return out
}

type Position struct {
	x int
	y int
}

func (this Position) String() string {
	return fmt.Sprintf("[%v|%v]", this.x, this.y)
}

func (this *Position) up() Position {
	return Position{
		x: this.x,
		y: this.y + 1,
	}
}
func (this *Position) down() Position {
	return Position{
		x: this.x,
		y: this.y - 1,
	}
}
func (this *Position) right() Position {
	return Position{
		x: this.x + 1,
		y: this.y,
	}
}
func (this *Position) left() Position {
	return Position{
		x: this.x - 1,
		y: this.y,
	}
}

func (this *Position) touches(other *Position) bool {
	dx := helpers.Abs(this.x - other.x)
	dy := helpers.Abs(this.y - other.y)

	return dx <= 1 && dy <= 1
}

func simulate(lines []string) int {
	moves := parseMove(lines)
	headPositions := []Position{{x: 0, y: 0}}
	tailPositions := []Position{{x: 0, y: 0}}

	for _, move := range moves {
		for i := 0; i < move.steps; i++ {
			head := headPositions[len(headPositions)-1]
			switch move.direction {
			case "U":
				head = head.up()
			case "D":
				head = head.down()
			case "R":
				head = head.right()
			case "L":
				head = head.left()
			}
			headPositions = append(headPositions, head)
			tail := tailPositions[len(tailPositions)-1]
			if !tail.touches(&head) {
				tailPositions = append(tailPositions, headPositions[len(headPositions)-2])
			}
		}
	}

	set := helpers.NewSet(tailPositions)
	values := set.AsSlice()
	fmt.Println(len(tailPositions), len(values))

	return 0
}

func part1(file string) int {
	lines := helpers.ReadLines(file)

	return simulate(lines)
}

func main() {
	fmt.Println(part1("input"))
}
