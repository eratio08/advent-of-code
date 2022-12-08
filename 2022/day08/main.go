package main

import (
	"aoc2022/helpers"
	"fmt"
	"sort"
	"strings"
)

type Forrest struct {
	trees  []int
	width  int
	height int
}

func newForrest(lines []string) Forrest {
	height := len(lines)
	width := len(lines[0])
	trees := make([]int, 0, height*width)
	for _, line := range lines {
		chars := helpers.Map(helpers.ToInt)(strings.Split(line, ""))
		trees = append(trees, chars...)
	}

	return Forrest{
		trees:  trees,
		width:  width,
		height: height,
	}
}

func (this *Forrest) get(x int, y int) int {
	if x < 0 || y < 0 || y >= this.height || x >= this.width {
		panic(fmt.Sprint("position is not in the forrest", x, y))
	}

	return this.trees[(y*this.width)+x]
}

func (this *Forrest) isVisible(x, y int) bool {
	tree := this.get(x, y)
	isVisibleTop := true
	for _, i := range helpers.MakeRange(y-1, 0) {
		isVisibleTop = isVisibleTop && (tree > this.get(x, i))
		if !isVisibleTop {
			break
		}
	}

	isVisibleRight := true
	for _, i := range helpers.MakeRange(x+1, this.width-1) {
		isVisibleRight = isVisibleRight && (tree > this.get(i, y))
		if !isVisibleRight {
			break
		}
	}

	isVisibleButtom := true
	for _, i := range helpers.MakeRange(y+1, this.height-1) {
		isVisibleButtom = isVisibleButtom && (tree > this.get(x, i))
		if !isVisibleButtom {
			break
		}
	}

	isVisibleLeft := true
	for _, i := range helpers.MakeRange(0, x-1) {
		isVisibleLeft = isVisibleLeft && (tree > this.get(i, y))
		if !isVisibleLeft {
			break
		}
	}

	return isVisibleTop || isVisibleRight || isVisibleButtom || isVisibleLeft
}

func (this *Forrest) visibleTrees() (out []int) {
	for y := 1; y < this.height-1; y++ {
		for x := 1; x < this.width-1; x++ {
			if this.isVisible(x, y) {
				out = append(out, this.get(x, y))
			}
		}
	}

	return out
}

func part1() {
	lines := helpers.ReadLines("input")
	forrest := newForrest(lines)
	visibleTrees := forrest.visibleTrees()
	inner := len(visibleTrees)
	outer := (2 * forrest.width) + (2 * forrest.height) - 4

	fmt.Println(inner, outer, inner+outer)
}

func (this *Forrest) scenicScore(x, y int) int {
	tree := this.get(x, y)

	topScore := 0
	for _, i := range helpers.MakeRange(y-1, 0) {
		t := this.get(x, i)
		topScore++
		if tree <= t {
			break
		}
	}

	bottomScore := 0
	for _, i := range helpers.MakeRange(y+1, this.height-1) {
		t := this.get(x, i)
		bottomScore++
		if tree <= t {
			break
		}
	}

	rightScore := 0
	for _, i := range helpers.MakeRange(x+1, this.width-1) {
		t := this.get(i, y)
		rightScore++
		if tree <= t {
			break
		}
	}

	leftScore := 0
	for _, i := range helpers.MakeRange(x-1, 0) {
		t := this.get(i, y)
		leftScore++
		if tree <= t {
			break
		}
	}

	return topScore * rightScore * bottomScore * leftScore
}

func (this *Forrest) scenicScores() (out []int) {
	for y := 1; y < this.height-1; y++ {
		for x := 1; x < this.width-1; x++ {
			out = append(out, this.scenicScore(x, y))
		}
	}

	return out
}

func part2() {
	lines := helpers.ReadLines("input")
	forrest := newForrest(lines)
	scores := forrest.scenicScores()
	sort.Ints(scores)

	fmt.Println(scores[len(scores)-1])
}

func main() {
	// part1()
	part2()
}
