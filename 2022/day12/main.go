package main

import (
	"aoc2022/helpers"
	"fmt"
	"math"
	"sort"
	"strings"
)

type (
	Hill struct {
		start   Point
		end     Point
		rows    int
		columns int
		heights map[Point]int
	}
	Graph struct {
		v []Point
		e map[Point][]Point
	}
	Point struct {
		x int
		y int
	}
)

func (this Point) string() string {
	return fmt.Sprintf("Point{x: %v, y: %v}", this.x, this.y)
}

func (this Graph) string() string {
	return fmt.Sprintf("Graph{v: %v, e: %v}", this.v, this.e)
}

func (this *Hill) canMove(p1 *Point, p2 *Point) bool {
	heightP1 := this.heights[*p1]
	heightP2 := this.heights[*p2]

	return heightP2 == heightP1+1 || heightP2 <= heightP1
}

func (this *Point) surroundings(hill *Hill) (out []Point) {
	s := [][2]int{{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
	for _, d := range s {
		p := Point{this.x + d[0], this.y + d[1]}
		if p.y >= 0 && p.y < hill.rows && p.x >= 0 && p.x < hill.columns {
			if hill.canMove(this, &p) {
				out = append(out, p)
			}
		}
	}

	return out
}

func newHill(lines []string) Hill {
	rows := len(lines)
	columns := len(lines[0])
	var start Point
	var end Point
	heights := map[Point]int{}

	for y, vs := range lines {
		for x, v := range strings.Split(vs, "") {
			p := Point{x, y}
			if v == "S" {
				heights[p] = int("a"[0])
				start = p
			} else if v == "E" {
				heights[p] = int("z"[0])
				end = p
			} else {
				heights[p] = int(v[0])
			}
		}
	}

	return Hill{
		start:   start,
		end:     end,
		rows:    rows,
		columns: columns,
		heights: heights,
	}
}

func (this *Hill) height(p *Point) int {
	return this.heights[*p]
}

func newGraph(hill *Hill) Graph {
	vs := []Point{}
	es := map[Point][]Point{}
	for y := 0; y < hill.rows; y++ {
		for x := 0; x < hill.columns; x++ {
			v := Point{x, y}
			vs = append(vs, v)
			es[v] = v.surroundings(hill)
		}
	}

	return Graph{
		v: vs,
		e: es,
	}
}

func (this *Graph) djikstra(start Point, end Point) int {
	dist := map[Point]int{}
	prev := map[Point]*Point{}
	visited := map[Point]bool{}
	q := []Point{}

	for _, v := range this.v {
		dist[v] = math.MaxInt / 2
		prev[v] = nil
		q = append(q, v)
	}

	dist[start] = 0

	for len(q) > 0 {
		sort.Slice(q, func(i, j int) bool {
			a := q[i]
			b := q[j]
			return dist[a] < dist[b]
		})
		u := q[0]
		q = q[1:]
		visited[u] = true

		if u.x == end.x && u.y == end.y {
			return dist[end]
		}

		for _, v := range this.e[u] {
			if _, ok := visited[v]; !ok {
				alt := dist[u] + 1 /* any distance to a naigbour is 1 here */

				if alt < dist[v] {
					dist[v] = alt
					prev[v] = &u
				}
			}
		}
	}

	panic("Did not find end")
}

func part1(lines []string) int {
	h := newHill(lines)
	g := newGraph(&h)
	dist := g.djikstra(h.start, h.end)

	return dist
}

func part2(lines []string) int {
	h := newHill(lines)
	g := newGraph(&h)

	aPoints := []Point{}
	lowest := h.heights[h.start]
	for k, v := range h.heights {
		if v == lowest {
			aPoints = append(aPoints, k)
		}
	}

	shortest := math.MaxInt
	for _, p := range aPoints {
		l := g.djikstra(p, h.end)
		fmt.Println(p, "->", h.end, "=", l)
		if l < shortest {
			shortest = l
		}
	}

	return shortest
}

func main() {
	lines := helpers.ReadLines("input")
	fmt.Println(part1(lines))
	fmt.Println(part2(lines))
}
