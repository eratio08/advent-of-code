package main

import (
	"aoc2022/helpers"
	"fmt"
	"regexp"
	"strings"
)

type Graph struct {
	valves map[string]*Valve
	root   string
}

func (this Graph) String() string {
	return fmt.Sprintf("Graph{valves: %v, root: %v}", this.valves, this.root)
}

type Valve struct {
	flowRate uint
	children []string
	parent   *Valve
}

func buildGraph(lines []string) Graph {
	valves := map[string]*Valve{}
	var root string
	for i, line := range lines {
		matcher := regexp.MustCompile(`^Valve (?P<node>\w{2}) has flow rate=(?P<rate>\d+); tunnels? leads? to valves? (?P<children>.*)`)
		matches := matcher.FindStringSubmatch(line)
		label := matches[1]
		flowRate := helpers.ToUint(matches[2])
		children := strings.Split(matches[3], ", ")
		node := &Valve{flowRate: flowRate, children: []string{}, parent: nil}
		valves[label] = node
		for _, child := range children {
			node.children = append(node.children, child)
		}
		if i == 0 {
			root = label
		}
	}

	return Graph{valves: valves, root: root}
}

func (this *Graph) bfs() int {
	flow := 0
	maxFlow := 0
	time := 0

	opened := map[string]bool{}
	visited := map[string]bool{}
	queue := []string{this.root}
	for len(queue) > 0 {
		if time >= 30 {
			break
		}
		/* move */
		v := queue[0]
		queue = queue[1:]
		if _, known := visited[v]; !known {
			fmt.Printf("== Minute %v ==\nValves %v are open, releasing %v preassure.\n", time, opened, flow)
			fmt.Println("Move to", v)
			time++
			visited[v] = true
			valve := this.valves[v]
			for _, c := range valve.children {
				queue = append(queue, c)
			}
			if _, alreadyOpen := opened[v]; valve.flowRate > 0 && !alreadyOpen {
				fmt.Printf("== Minute %v ==\nValves %v are open, releasing %v preassure.\n", time, opened, flow)
				fmt.Println("Opening", v, "with rate", valve.flowRate)
				/* open */
				opened[v] = true
				time++
				flow += int(valve.flowRate)
				maxFlow += flow
			}
		}
		maxFlow += flow
	}

	for i := time; i <= 30; i++ {
		fmt.Printf("== Minute %v ==\nValves %v are open, releasing %v preassure.\n", i, opened, flow)
		maxFlow += flow
	}

	return maxFlow
}

func (this *Graph) dfs() int {
	flow := 0
	maxFlow := 0
	time := 0

	opened := map[string]bool{}
	visited := map[string]bool{}
	stack := []string{this.root}
	for len(stack) > 0 {
		if time >= 30 {
			break
		}
		/* move */
		v := stack[0]
		stack = stack[1:]
		if _, known := visited[v]; !known {
			fmt.Printf("== Minute %v ==\nValves %v are open, releasing %v preassure.\n", time, opened, flow)
			fmt.Println("Move to", v)
			time++
			visited[v] = true
			valve := this.valves[v]
			tmp := append([]string{}, valve.children...)
			stack = append(tmp, stack...)
			if _, alreadyOpen := opened[v]; valve.flowRate > 0 && !alreadyOpen {
				fmt.Printf("== Minute %v ==\nValves %v are open, releasing %v preassure.\n", time, opened, flow)
				fmt.Println("Opening", v, "with rate", valve.flowRate)
				/* open */
				opened[v] = true
				time++
				flow += int(valve.flowRate)
				maxFlow += flow
			}
		}
		maxFlow += flow
	}

	for i := time; i <= 30; i++ {
		fmt.Printf("== Minute %v ==\nValves %v are open, releasing %v preassure.\n", i, opened, flow)
		maxFlow += flow
	}

	return maxFlow

}

func part1(lines []string) int {
	g := buildGraph(lines)
	// fmt.Println(g)
	// fmt.Println(g.bfs())
	fmt.Println(g.dfs())

	return 0
}

func main() {
	lines := helpers.ReadLines("test")
	fmt.Println(part1(lines))

}
