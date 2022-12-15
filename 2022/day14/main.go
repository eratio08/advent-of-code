package main

import (
	"aoc2022/helpers"
	"fmt"
	"strings"
)

type Kind uint

const (
	Rock Kind = iota
	Sand
)

type Cave struct {
	matter     [Y_MAX][X_MAX]*Matter
	movingSand *Matter
}

type Matter struct {
	x int
	y int
	t Kind
}

type Path struct {
	points [][2]int
}

const (
	X_OFFSET int = 480
	X_MAX    int = 550 - X_OFFSET
	Y_MAX    int = 170
	SAND_X       = 500 - X_OFFSET
)

func parsePath(line string) Path {
	points := strings.Split(line, " -> ")
	path := Path{}
	for _, point := range points {
		coord := strings.Split(point, ",")
		path.points = append(path.points, [2]int{helpers.ToInt(coord[0]) - X_OFFSET, helpers.ToInt(coord[1])})
	}

	return path
}

func parsePaths(lines []string) (out []*Path) {
	for _, line := range lines {
		path := parsePath(line)
		out = append(out, &path)
	}

	return out
}

func (this *Path) toRocks() (out []*Matter) {
	prev := this.points[0]
	for _, point := range this.points[1:] {
		xprev := prev[0]
		yprev := prev[1]
		x := point[0]
		y := point[1]
		/* horizontal */
		if y-yprev == 0 {
			for _, xn := range helpers.MakeRange(xprev, x) {

				out = append(out, &Matter{xn, y, Rock})
			}
		}
		/* vertical */
		if x-xprev == 0 {
			for _, yn := range helpers.MakeRange(yprev, y) {
				out = append(out, &Matter{x, yn, Rock})
			}
		}
		prev = point
	}

	/* has duplicates */
	return out
}

func newCave(paths []*Path) Cave {
	rocks := helpers.FlatMap(func(p *Path) []*Matter { return p.toRocks() })(paths)
	sand := &Matter{SAND_X, 0, Sand}
	cave := Cave{[Y_MAX][X_MAX]*Matter{}, sand}
	cave.matter[0][SAND_X] = sand
	for _, rock := range rocks {
		cave.matter[rock.y][rock.x] = rock
	}

	return cave
}

func (this Cave) String() (out string) {
	for y := 0; y < Y_MAX; y++ {
		for x := 0; x < X_MAX; x++ {
			matter := this.matter[y][x]
			if matter == nil {
				out = fmt.Sprint(out, ".")
			} else if matter.t == Rock {
				out = fmt.Sprint(out, "#")
			} else {
				out = fmt.Sprint(out, "O")
			}
		}
		out = fmt.Sprint(out, "\n")
	}

	return out
}

func (this *Cave) tick() {
	if this.movingSand == nil {
		return
	}

	sandX := this.movingSand.x
	sandY := this.movingSand.y
	/* try fall */
	if this.matter[sandY+1][sandX] == nil {
		this.movingSand.y = sandY + 1
		this.matter[sandY][sandX] = nil
		this.matter[sandY+1][sandX] = this.movingSand
	} else
	/* diagonal left */
	if this.matter[sandY+1][sandX-1] == nil {
		this.movingSand.x = sandX - 1
		this.movingSand.y = sandY + 1
		this.matter[sandY][sandX] = nil
		this.matter[sandY+1][sandX-1] = this.movingSand
	} else
	/* diagonal right */
	if this.matter[sandY+1][sandX+1] == nil {
		this.movingSand.x = sandX + 1
		this.movingSand.y = sandY + 1
		this.matter[sandY][sandX] = nil
		this.matter[sandY+1][sandX+1] = this.movingSand
	} else {
		// this.movingSand =
	}

}

func part1(lines []string) int {
	paths := parsePaths(lines)
	cave := newCave(paths)
	fmt.Println(cave)

	return 0
}

func main() {
	lines := helpers.ReadLines("test")
	fmt.Println(part1(lines))
}
