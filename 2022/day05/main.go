package main

import (
	"aoc2022/helpers"
	"container/list"
	"fmt"
	"strconv"
	"strings"
)

func pivot(lines []string) []string {
	pivoted := make([]string, len(lines[0]))

	for i := len(lines) - 1; i >= 0; i-- {
		for j, char := range lines[i] {
			pivoted[j] += string(char)
		}
	}

	return pivoted
}

func split(lines []string) ([]string, []string) {
	var index int
	for i := 0; i < len(lines); i++ {
		if lines[i] == "" {
			index = i
			break
		}
	}

	return lines[:index], lines[index+1:]
}

func parseStacks(lines []string) []list.List {
	supplyStackCount := (len(lines[0]) / 4) + 1
	stacks := make([]list.List, supplyStackCount)
	for _, list := range stacks {
		list = *list.Init()
	}
	pivoted := pivot(lines)

	for _, line := range pivoted {
		if i, err := strconv.Atoi(string(line[0])); err == nil {
			line = strings.Trim(line, " ")
			for j := 1; j < len(line); j++ {
				stacks[i-1].PushFront(string(line[j]))
			}
		}
	}

	return stacks
}

type Move struct {
	count int
	from  int
	to    int
}

func parseMoves(lines []string) []Move {
	moves := make([]Move, len(lines))

	for i, line := range lines {
		parts := strings.Split(line, " ")
		count, _ := strconv.Atoi(parts[1])
		from, _ := strconv.Atoi(parts[3])
		to, _ := strconv.Atoi(parts[5])
		moves[i] = Move{
			count: count,
			from:  from - 1,
			to:    to - 1,
		}
	}

	return moves
}

func parseInput(file string) ([]list.List, []Move) {
	lines := helpers.ReadLines(file)
	stackLines, moveLines := split(lines)
	stacks := parseStacks(stackLines)
	moves := parseMoves(moveLines)

	return stacks, moves
}

func printStack(stack list.List) {
	for e := stack.Front(); e != nil; e = e.Next() {
		fmt.Print(e.Value)
	}
}

func printStacks(stacks *[]list.List) {
	for i, l := range *stacks {
		fmt.Print(i, "->")
		printStack(l)
		fmt.Print("\n")
	}
	fmt.Print("\n")
}

func getTop(stacks []list.List) string {
	var tops string
	for _, stack := range stacks {
		e := stack.Front().Value.(string)
		tops += e
	}

	return tops
}

func part1(file string) string {
	stacks, moves := parseInput(file)

	for _, move := range moves {
		for i := 0; i < move.count; i++ {
			s1 := &stacks[move.from]
			e := s1.Front()
			s1.Remove(e)

			s2 := &stacks[move.to]
			s2.PushFront(e.Value)
		}
	}

	return getTop(stacks)
}

func part2(file string) string {
	stacks, moves := parseInput(file)

	printStacks(&stacks)
	for _, move := range moves {
		tmp := list.New()
		for i := 0; i < move.count; i++ {
			s1 := &stacks[move.from]
			e := s1.Front()
			s1.Remove(e)

			tmp.PushBack(e.Value)
		}

		s2 := &stacks[move.to]
		s2.PushFrontList(tmp)
	}
	printStacks(&stacks)

	return getTop(stacks)
}

func main() {
	// fmt.Println(part1("input"))
	fmt.Println(part2("input"))

}
