package main

import (
	"aoc2022/helpers"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestPart1(t *testing.T) {
	rootNumber := part1(helpers.ReadLines("test"))

	assert.Equal(t, 152, rootNumber)
}
