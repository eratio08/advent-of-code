package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestMoveTo(t *testing.T) {
	p := Position{x: 2, y: 2}
	p1 := Position{x: 2, y: 2}

	assert.Equal(t, p, p.moveTo(&p1))
}
