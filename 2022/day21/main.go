package main

import (
	"aoc2022/helpers"
	"fmt"
	"strings"
)

func parse(lines []string) map[string]func() int {
	ms := map[string]func() int{}
	for _, line := range lines {
		parts := strings.Split(line, ": ")
		name := parts[0]
		if len(parts[1]) > 8 {
			parts = strings.Split(parts[1], " ")
			m1 := parts[0]
			op := parts[1]
			m2 := parts[2]

			ms[name] = func() int {
				m1Value := ms[m1]()
				m2Value := ms[m2]()
				switch op {
				case "+":
					return m1Value + m2Value
				case "-":
					return m1Value - m2Value
				case "/":
					return m1Value / m2Value
				case "*":
					return m1Value * m2Value
				default:
					panic(op)
				}
			}
		} else {
			num := helpers.ToInt(parts[1])
			ms[name] = func() int { return num }
		}
	}

	return ms
}

func part1(lines []string) int {
	monkeys := parse(lines)

	return monkeys["root"]()
}

func main() {
	lines := helpers.ReadLines("input")
	fmt.Println(part1(lines))

}
