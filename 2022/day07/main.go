package main

import (
	"aoc2022/helpers"
	"fmt"
	"sort"
	"strings"
)

type Node struct {
	children map[string]Node
	size     int
}

func (i Node) IsDir() bool {
	return i.size == 0
}

func NewDir() Node {
	return Node{children: map[string]Node{}}
}

func NewFile(size int) Node {
	return Node{size: size}
}

func (i Node) Add(path []string, size int) {
	if len(path) == 1 {
		i.children[path[0]] = NewFile(size)
	} else {
		dir := path[0]
		if _, ok := i.children[dir]; !ok {
			i.children[dir] = NewDir()
		}
		i.children[dir].Add(path[1:], size)
	}
}

func (i Node) Size() int {
	if !i.IsDir() {
		return i.size
	}

	return helpers.Sum(helpers.Map(Node.Size)(helpers.Values(i.children)))
}

func getDirSizes(lines []string) []int {
	dirSizes := make([]int, len(lines))
	root := NewDir()

	path := make([]string, 0, len(lines))
	for _, line := range lines {
		if line[0] == '$' {
			cmd := strings.Split(line, " ") // [$,cmd,...]
			if cmd[1] != "cd" {
				continue
			}

			switch cmd[2] {
			case "/":
				path = []string{}
			case "..":
				path = path[:len(path)-1]
			default:
				path = append(path, cmd[2])
			}
		} else {
			fileInfo := strings.Split(line, " ") // 'dir name' or 'size name'
			if fileInfo[0] == "dir" {
				continue
			}
			root.Add(append(path, fileInfo[1]), helpers.ToInt(fileInfo[0]))
		}
	}

	q := []Node{root}

	for len(q) > 0 {
		next := q[0]
		q = q[1:]

		if next.IsDir() {
			dirSizes = append(dirSizes, next.Size())
		}

		for _, v := range next.children {
			q = append(q, v)
		}
	}

	return dirSizes
}

func part1(file string) int {
	lines := helpers.ReadLines(file)
	dirSizes := getDirSizes(lines)
	greater := func(s int) bool { return s <= 100000 }

	return helpers.Sum(helpers.Filter(greater)(dirSizes))
}

func part2(file string) int {
	lines := helpers.ReadLines(file)
	dirSizes := getDirSizes(lines)
	sort.Ints(dirSizes) // sort increasing
	total := 70000000
	rootSize := dirSizes[len(dirSizes)-1]
	for _, o := range dirSizes {
		if rootSize-o <= total-30000000 {
			return o
		}
	}
	panic("no answer")
}

func main() {
	fmt.Println(part1("input"))
	fmt.Println(part2("input"))
}
