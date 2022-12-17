package main

import (
	"aoc2022/helpers"
	"fmt"
	"regexp"
)

type Graph struct {
	nodes map[string]*Node
	root  *Node
}

type Node struct {
	weight   int
	children []*Node
}

func buildGraph(lines []string) Graph {
	for _, line := range lines {
		// Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
		matcher := regexp.MustCompile(`^Valve (?P<node>\w{2}) has flow rate=(?P<rate>\d+); tunnels? leads? to valves? (?P<children>.*)`)
		matches := matcher.FindStringSubmatch(line)
		fmt.Println(matches[1][0])
	}

	return Graph{}
}

func part1(lines []string) int {
	return 0
}

func main() {
	lines := helpers.ReadLines("test")
	buildGraph(lines)

}
