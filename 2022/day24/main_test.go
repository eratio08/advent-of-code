package main

import (
	"aoc2022/helpers"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestPart1(t *testing.T) {
	lines := helpers.ReadLines("test")

	assert.Equal(t, 18, part1(lines))
}

func TestPart2(t *testing.T) {
	lines := helpers.ReadLines("test")

	assert.Equal(t, 54, part2(lines))
}
