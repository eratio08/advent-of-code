package main

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestDiagonal(t *testing.T) {
	p := pos{-3, 15}
	p2 := p.intoDiagonalPos().intoPos()

	assert.Equal(t, p, p2)
}

func TestRange(t *testing.T) {
	l := pos{2, 1}
	b := pos{-2, 15}
	s := sensor{
		location: l,
		beacon:   b,
		distance: l.distance(&b),
	}

	ranges := s.rangesAtY(10)
	fmt.Println(ranges)
}
