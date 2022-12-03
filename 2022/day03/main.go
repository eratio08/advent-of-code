package main

import (
	"aoc2022/helpers"
	"fmt"
)

type Set map[rune]bool

func newSet(str *string) Set {
	set := map[rune]bool{}
	for _, i := range *str {
		set[i] = true
	}

	return set

}

type Rucksack struct {
	comp1 Set
	comp2 Set
}

func rucksackFromLine(line *string) Rucksack {
	comp1 := (*line)[:len(*line)/2]
	comp2 := (*line)[len(*line)/2:]
	return Rucksack{
		comp1: newSet(&comp1),
		comp2: newSet(&comp2),
	}
}

func (this *Rucksack) findDouble() int {
	for key := range this.comp1 {
		_, exists := this.comp2[key]
		if exists {
			score := scoreLetter(&key)
			fmt.Println(string(key), " -> ", score)
			return score
		}
	}

	panic("No doubling")
}

func scoreLetter(letter *rune) int {
	codepoint := int(*letter)
	if codepoint <= 90 {
		return codepoint - 38
	} else {
		return codepoint - 96
	}
}

func part1(file string) int {
	lines := helpers.ReadLines(file)

	var sum int
	for _, line := range lines {
		if line == "" {
			continue
		}
		rucksack := rucksackFromLine(&line)
		sum += rucksack.findDouble()
	}

	return sum
}

type ElfGroup [3]Set

func (this *ElfGroup) findBadge() int {
	for key := range this[0] {
		_, exists2 := this[1][key]
		_, exists3 := this[2][key]
		if exists2 && exists3 {
			return scoreLetter(&key)
		}
	}

	panic("No trippeling")
}

func buildGroups(lines []string) []ElfGroup {
	groups := make([]ElfGroup, 0, len(lines)/3)
	for i := 0; i < len(lines); i += 3 {
		group := ElfGroup{newSet(&lines[i]), newSet(&lines[i+1]), newSet(&lines[i+2])}
		groups = append(groups, group)
	}

	return groups
}

func part2(file string) int {
	lines := helpers.ReadLines(file)
	groups := buildGroups(lines)

	var sum int
	for _, group := range groups {
		sum += group.findBadge()
	}

	return sum
}

func main() {
	// fmt.Println(part1("input"))
	fmt.Println(part2("input"))
}
