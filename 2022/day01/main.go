package main

import (
	"aoc2022/helpers"
	"fmt"
	"log"
	"os"
	"sort"
	"strconv"
)

func findMax(lines []string) int {
	max, curSum := 0, 0
	for _, line := range lines {
		if line == "" {
			if curSum > max {
				max = int(curSum)
			}
			curSum = 0
		} else {
			i, err := strconv.Atoi(line)
			if err != nil {
				log.Println()
				os.Exit(1)
			}

			curSum += i
		}
	}

	return max
}

func part1() {
	lines := helpers.ReadLines("input01")
	result := findMax(lines)

	fmt.Print(result)
}

func determineTop3(top3 *[]int, candidate int) {
	if len(*top3) < 3 {
		intSlice := sort.IntSlice(append(*top3, candidate))
		sort.Slice(intSlice, func(x, y int) bool {
			return y < x
		})
		(*top3) = intSlice
	} else {
		c := candidate
		for i, e := range *top3 {
			if e <= c {
				old := (*top3)[i]
				(*top3)[i] = c
				c = old
			}
		}
	}
}

func findSumOfTop3(lines []string) int {
	top3 := make([]int, 0, 3)

	var curSum int
	for _, line := range lines {
		if line == "" {
			determineTop3(&top3, curSum)
			fmt.Println(curSum, top3)

			curSum = 0
		} else {
			i, err := strconv.Atoi(line)
			if err != nil {
				log.Println()
				os.Exit(1)
			}

			curSum += i
		}
	}

	var sum int
	for _, i := range top3 {
		sum += i
	}

	return sum
}

func part2() {
	lines := helpers.ReadLines("input01")
	result := findSumOfTop3(lines)

	fmt.Print(result)
}

func main() {
	// part1()
	part2()
}
