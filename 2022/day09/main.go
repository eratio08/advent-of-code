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
func (this *Position) upRight() Position {
	return Position{
		x: this.x + 1,
		y: this.y + 1,
	}
}
func (this *Position) upLeft() Position {
	return Position{
		x: this.x - 1,
		y: this.y + 1,
	}
}
func (this *Position) downLeft() Position {
	return Position{
		x: this.x - 1,
		y: this.y - 1,
	}
}
func (this *Position) downRight() Position {
	return Position{
		x: this.x + 1,
		y: this.y - 1,
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

	return len(values)
}

func part1(file string) int {
	lines := helpers.ReadLines(file)

	return simulate(lines)
}

func (this *Position) moveTo(other *Position) Position {
	dy := this.y - other.y
	dx := this.x - other.x

	if dx == 0 {
		/* vertical */
		if dy < -1 {
			// below
			return this.up()
		} else if dy > 1 {
			// above
			return this.down()
		}
	} else if dy == 0 {
		/* horizontal */
		if dx < -1 {
			//left
			return this.right()
		} else if dx > 1 {
			//right
			return this.left()
		}
	} else {
		/* diagonal */
		d := helpers.Abs((dx * dy) / 2)
		if d >= 1 {
			if this.x > other.y && this.y > other.y {
				//top right
				return this.downLeft()
			} else if this.x < other.x && this.y > other.y {
				// top left
				return this.downRight()
			} else if this.x < other.x && this.y < other.y {
				// bottom left
				return this.upRight()
			} else if this.x > other.x && this.y < other.y {
				//bottom right
				return this.upLeft()
			}
		}
	}

	return *this
}

func simulateN(lines []string, n int) int {
	moves := parseMove(lines)
	head := Position{x: 0, y: 0}
	knots := make([]Position, 0, n)
	for i := 0; i < n; i++ {
		knots = append(knots, Position{x: 0, y: 0})
	}
	tailPositions := make([]Position, 0, len(moves))

	for _, move := range moves {
		for i := 0; i < move.steps; i++ {
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
			currentHead := head
			for i, knot := range knots {
				maybeNewPos := knot.moveTo(&currentHead)
				// fmt.Println("move", move, "knot", knot, "currentHead", currentHead, "maybeNewPos", maybeNewPos)
				knots[i] = maybeNewPos
				currentHead = maybeNewPos
			}
			tailPositions = append(tailPositions, knots[len(knots)-1])
		}
		fmt.Println(move, head, "->", knots, "<-", tailPositions)
	}
	set := helpers.NewSet(tailPositions)
	values := set.AsSlice()
	// fmt.Println(tailPositions)
	// fmt.Println(values)

	return len(values)
}
func part2(file string) int {
	lines := helpers.ReadLines(file)

	return simulateN(lines, 9)
}

func main() {
	fmt.Println(part1("input"))
	// fmt.Println(part2("input"))
	// fmt.Println(part2("test2"))
	fmt.Println(part2("test"))
}
