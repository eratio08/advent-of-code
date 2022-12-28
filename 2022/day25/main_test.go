package main

import (
	"aoc2022/helpers"
	"fmt"
	"math"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestPart1(t *testing.T) {
	lines := helpers.ReadLines("test")

	assert.Equal(t, "2=-1=0", string(part1(lines)))
}

func TestRem(t *testing.T) {
	fmt.Println(3 % 5)
	fmt.Println(198%5, 198/5, 39*5, math.Sqrt(39*5))
}

func TestPart2(t *testing.T) {

}
