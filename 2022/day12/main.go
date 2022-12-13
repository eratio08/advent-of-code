package main

import (
	"aoc2022/helpers"
	"fmt"
	"strings"
)

/*
 graphs
  * dense = E > V -> matrix
  * sparse = E < V -> lists
*/

type (
	Graph struct {
		start   Point
		end     Point
		rows    int
		columns int
		heights [][]int
	}
	Vertex struct {
		cost  int
		point Point
	}
	Point struct {
		x int
		y int
	}
)

func (this Point) String() string {
	return fmt.Sprintf("Point{x: %v, y: %v}", this.x, this.y)
}

func (this *Point) surroundings(rows, columns int) (out []Point) {
	/* up */
	if this.y > 0 {
		out = append(out, Point{this.x, this.y - 1})
	}
	/* down */
	if this.y < rows-1 {
		out = append(out, Point{this.x, this.y + 1})
	}
	/* left */
	if this.x > 0 {
		out = append(out, Point{this.x - 1, this.y})
	}
	/* right */
	if this.x < columns-1 {
		out = append(out, Point{this.x + 1, this.y})
	}

	return out
}

func (this Vertex) String() string {
	return fmt.Sprintf("Vertex{x: %v, y: %v}", this.point.x, this.point.y)
}

func buildGraph(lines []string) Graph {
	rows := len(lines)
	columns := len(lines[0])
	var start Point
	var end Point
	heights := make([][]int, rows)
	for j := 0; j < rows; j++ {
		heights[j] = make([]int, columns)
	}

	for y, vs := range lines {
		for x, v := range strings.Split(vs, "") {
			if v == "S" {
				heights[y][x] = int("a"[0])
				start = Point{x, y}
			} else if v == "E" {
				heights[y][x] = int("z"[0])
				end = Point{x, y}
			} else {
				heights[y][x] = int(v[0])
			}
		}
	}

	return Graph{
		start:   start,
		end:     end,
		rows:    rows,
		columns: columns,
		heights: heights,
	}
}

func (this *Graph) djikstra() int {
	visited := helpers.NewSet([]string{})
	queue := []Vertex{{0, this.start}}

	for len(queue) != 0 {
		v1 := queue[0]
		fmt.Println("v1", v1)
		if v1.point.x == this.end.x && v1.point.y == this.end.y {
			return v1.cost
		}
		queue = queue[1:]
		height := this.heights[v1.point.y][v1.point.x]

		for _, point := range v1.point.surroundings(this.rows, this.columns) {
			pointHeight := this.heights[point.y][point.x]
			fmt.Println(point, pointHeight, height)
			if pointHeight <= height || pointHeight == height+1 {
				v2 := Vertex{v1.cost + 1, point}
				fmt.Println(v2)
				if visited.Add(fmt.Sprint(v2)) {
					queue = append(queue, v2)
				}
			}
		}
		fmt.Println("visited", visited)
		fmt.Println("queue", queue)
		fmt.Println()
	}

	panic("Did not find end")
}

func part1(lines []string) uint {
	g := buildGraph(lines)
	fmt.Println(g)

	return uint(g.djikstra())
}

func main() {
	lines := helpers.ReadLines("test")
	fmt.Println(part1(lines))
}
