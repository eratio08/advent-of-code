package main

import (
	"aoc2022/helpers"
	"fmt"
	"strings"
)

type Matter uint

const (
	Rock Matter = iota
	Sand
)

func (this Matter) String() string {
	switch this {
	case Rock:
		return "#"
	case Sand:
		return "o"
	default:
		return "."
	}
}

type Cave struct {
	matter     map[Pos]Matter
	movingSand *Pos
	minPos     Pos
	maxPos     Pos
	maxSand    int
}

type Pos struct {
	x, y int
}

type Path struct {
	points [][2]int
}

func (this *Path) toPos() (out []Pos) {
	prev := this.points[0]
	for _, point := range this.points[1:] {
		xprev := prev[0]
		yprev := prev[1]
		x := point[0]
		y := point[1]
		/* horizontal */
		if y-yprev == 0 {
			for _, xn := range helpers.MakeRange(xprev, x) {

				out = append(out, Pos{xn, y})
			}
		}
		/* vertical */
		if x-xprev == 0 {
			for _, yn := range helpers.MakeRange(yprev, y) {
				out = append(out, Pos{x, yn})
			}
		}
		prev = point
	}

	/* has duplicates */
	return out

}

const (
	X_OFFSET int = 480
	X_MAX    int = 550 - X_OFFSET
	Y_MAX    int = 170
	SAND_X       = 500
)

func parsePath(line string) Path {
	points := strings.Split(line, " -> ")
	path := Path{}
	for _, point := range points {
		coord := strings.Split(point, ",")
		path.points = append(path.points, [2]int{helpers.ToInt(coord[0]), helpers.ToInt(coord[1])})
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

func newCave(paths []*Path, withFloor bool) Cave {
	rocks := helpers.FlatMap(func(p *Path) []Pos { return p.toPos() })(paths)
	sand := Pos{SAND_X, 0}
	yMax := 0
	xMin := 500
	xMax := 0
	for _, k := range rocks {
		if k.x < xMin {
			xMin = k.x
		}
		if k.x > xMax {
			xMax = k.x
		}
		if k.y > yMax {
			yMax = k.y
		}
	}
	cave := Cave{map[Pos]Matter{}, &sand, Pos{xMin, 0}, Pos{xMax, yMax + 2}, 0}
	cave.matter[sand] = Sand
	if withFloor {
		floorPath := Path{[][2]int{{0, yMax + 2}, {1000, yMax + 2}}}
		rocks = append(rocks, floorPath.toPos()...)
	}
	for _, rock := range rocks {
		cave.matter[rock] = Rock
	}

	return cave
}

func (this Cave) String() (out string) {
	for y := 0; y <= this.maxPos.y; y++ {
		for x := this.minPos.x; x <= this.maxPos.x; x++ {
			p := Pos{x, y}
			matter, ok := this.matter[p]
			if !ok {
				out = fmt.Sprint(out, ".")
			} else {
				out = fmt.Sprint(out, matter)
			}
		}
		out = fmt.Sprint(out, "\n")
	}

	return out
}

func (this *Cave) tick() {
	moves := [][2]int{{0, 1}, {-1, 1}, {1, 1}}
	if this.movingSand == nil {
		this.movingSand = &Pos{SAND_X, 0}
		this.matter[*this.movingSand] = Sand
	}

	movingSand := this.movingSand
	for _, move := range moves {
		nextX := movingSand.x + move[0]
		nextY := movingSand.y + move[1]
		nextSand := Pos{nextX, nextY}
		if _, ok := this.matter[nextSand]; ok {
			continue
		}

		delete(this.matter, *this.movingSand)
		if nextSand.y > this.maxPos.y {
			this.movingSand = nil
			this.maxSand = this.countSand()
			break
		}
		this.matter[nextSand] = Sand
		this.movingSand = &nextSand
		break
	}
	if this.movingSand != nil && *this.movingSand == *movingSand {
		this.movingSand = nil
	}
}

func (this *Cave) countSand() (count int) {
	for _, v := range this.matter {
		if v == Sand {
			count += 1
		}
	}

	return count
}

func part1(lines []string) int {
	paths := parsePaths(lines)
	cave := newCave(paths, false)
	fmt.Println(cave)

	for cave.maxSand == 0 {
		cave.tick()
	}
	fmt.Println(cave)

	return cave.maxSand
}

func (this *Cave) tick2() {
	moves := [][2]int{{0, 1}, {-1, 1}, {1, 1}}
	if this.movingSand == nil {
		this.movingSand = &Pos{SAND_X, 0}
		this.matter[*this.movingSand] = Sand
	}

	movingSand := this.movingSand
	for _, move := range moves {
		nextX := movingSand.x + move[0]
		nextY := movingSand.y + move[1]
		nextSand := Pos{nextX, nextY}
		if _, ok := this.matter[nextSand]; ok {
			continue
		}

		delete(this.matter, *this.movingSand)
		this.matter[nextSand] = Sand
		this.movingSand = &nextSand
		break
	}
	if this.movingSand != nil && *this.movingSand == *movingSand {
		this.movingSand = nil
	}
}

func part2(lines []string) int {
	paths := parsePaths(lines)
	cave := newCave(paths, true)

	for i := 0; i < 10_000_000; i++ {
		cave.tick2()
	}
	fmt.Println(cave)

	return cave.countSand()

}

func main() {
	lines := helpers.ReadLines("input")
	// fmt.Println(part1(lines))
	fmt.Println(part2(lines))
}
