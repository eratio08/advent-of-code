package main

import (
	"aoc2022/helpers"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

type Range struct {
	start uint
	end   uint
}

func (this *Range) fullyIncludes(other *Range) bool {
	return this.start <= other.start && this.end >= other.end
}

func (this *Range) overlap(other *Range) bool {
	return this.fullyIncludes(other) ||
		other.fullyIncludes(this) ||
		/*  */
		(this.start <= other.start && this.end >= other.start) ||
		(other.start <= this.start && other.end >= this.start)
}

func (this *Range) width() uint {
	return this.end - this.start
}

func newRange(str *string) Range {
	parts := strings.Split(*str, "-")
	start, err := strconv.Atoi(parts[0])
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}

	end, err := strconv.Atoi(parts[1])
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}

	return Range{
		start: uint(start),
		end:   uint(end),
	}
}

func part1(file string) int {
	lines := helpers.ReadLines(file)
	var count int

	for _, line := range lines {
		parts := strings.Split(line, ",")
		r1 := newRange(&parts[0])
		r2 := newRange(&parts[1])

		if r1.fullyIncludes(&r2) || r2.fullyIncludes(&r1) {
			count += 1
		}
	}

	return count
}

func part2(file string) int {
	lines := helpers.ReadLines(file)
	var count int

	for _, line := range lines {
		parts := strings.Split(line, ",")
		r1 := newRange(&parts[0])
		r2 := newRange(&parts[1])

		if r1.overlap(&r2) {
			count += 1
		}
	}

	return count

}

func main() {
	// fmt.Println(part1("input"))
	fmt.Println(part2("input"))
}
