package main

// not my solution see https://github.com/rhighs/aoc2022/blob/master/day24/main.go

import (
	"aoc2022/helpers"
	"fmt"
	"strings"
)

func main() {
	lines := helpers.ReadLines("input")

	fmt.Println(part1(lines))
	fmt.Println(part2(lines))
}

func part1(lines []string) int {
	basin, blizzards, start, target := parse(lines)

	return traverseBasin(basin, blizzards, start, target)
}

func part2(lines []string) int {
	basin, blizzards, start, target := parse(lines)

	return traverseBasin(basin, blizzards, start, target) +
		traverseBasin(basin, blizzards, target, start) +
		traverseBasin(basin, blizzards, start, target)
}

type pos struct {
	x, y int
}

func (p *pos) add(other pos) pos {
	return pos{p.x + other.x, p.y + other.y}
}

type blizzard struct {
	pos, dir, wrap pos
}

var (
	UP    = pos{0, -1}
	DOWN  = pos{0, 1}
	LEFT  = pos{-1, 0}
	RIGHT = pos{1, 0}
)

var directions []pos = []pos{
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

type basin [][]rune

func parse(lines []string) (basin basin, blizzards []blizzard, start, target pos) {
	start.x = strings.Index(lines[0], ".")
	target.y = len(lines) - 1
	target.x = strings.Index(lines[target.y], ".")

	for _, line := range lines {
		line = strings.TrimSpace(line)
		basin = append(basin, []rune(line))
	}

	for y, row := range basin {
		for x, c := range row {
			switch c {
			case '^':
				blizzards = append(blizzards, blizzard{
					pos{x, y}, UP, pos{x, len(basin) - 2},
				})
			case 'v':
				blizzards = append(blizzards, blizzard{
					pos{x, y}, DOWN, pos{x, 1},
				})
			case '<':
				blizzards = append(blizzards, blizzard{
					pos{x, y}, LEFT, pos{len(basin[0]) - 2, y},
				})
			case '>':
				blizzards = append(blizzards, blizzard{
					pos{x, y}, RIGHT, pos{1, y},
				})
			}
		}
	}

	return
}

func (basin *basin) inBounds(pos pos) bool {
	return pos.x >= 0 && pos.x < len((*basin)[0]) && pos.y >= 0 && pos.y < len(*basin)
}

func traverseBasin(basin basin, blizzards []blizzard, start, target pos) int {
	minutes := 0
	currentStep := map[pos]bool{}
	currentStep[start] = true

	for !currentStep[target] {
		blizzardPositions := map[pos]bool{}
		for i, blizzard := range blizzards {
			newBlizzardPos := blizzard.pos.add(blizzard.dir)
			if basin.inBounds(newBlizzardPos) {
				if basin[newBlizzardPos.y][newBlizzardPos.x] == '#' {
					blizzards[i].pos = blizzard.wrap
				} else {
					blizzards[i].pos = newBlizzardPos
				}
			}
			blizzardPositions[blizzards[i].pos] = true
		}

		newStep := map[pos]bool{}
		for pos := range currentStep {
			if !(blizzardPositions[pos]) {
				newStep[pos] = true
			}
			for _, direction := range directions {
				newPos := pos.add(direction)
				if basin.inBounds(newPos) && basin[newPos.y][newPos.x] != '#' && !blizzardPositions[newPos] {
					newStep[newPos] = true
				}
			}
		}

		currentStep = newStep
		minutes++
	}

	return minutes
}

func (b blizzard) String() string {
	switch b.dir {
	case UP:
		return "^"
	case DOWN:
		return "v"
	case LEFT:
		return "<"
	case RIGHT:
		return ">"
	default:
		panic("invalid direction")
	}
}

func draw(basin basin, blizzards []blizzard, currentPos map[pos]bool, start, target pos) {
	bliz := map[pos]blizzard{}
	for _, b := range blizzards {
		bliz[b.pos] = b
	}

	for y, row := range basin {
		for x, c := range row {
			pos := pos{x, y}
			if b, ok := bliz[pos]; ok {
				fmt.Print(b)
			} else if currentPos[pos] {
				fmt.Print("E")
			} else if pos == start || pos == target {
				fmt.Print("e")
			} else {
				fmt.Print(string(c))
			}
		}
		fmt.Println()
	}
	fmt.Println()
}
