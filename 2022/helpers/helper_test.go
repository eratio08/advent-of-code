package helpers

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestFold(t *testing.T) {
	add := func(a int, e int) int {
		return a + e
	}
	sum := Foldr(add)(0)([]int{1, 2, 3, 4, 5})

	assert.Equal(t, 15, sum, "Sum after foldr should be 15")
}

func TestMap(t *testing.T) {
	inc := func(e int) int {
		return e + 1
	}
	res := Map(inc)([]int{1, 2, 3, 4, 5})

	assert.Equal(t, []int{2, 3, 4, 5, 6}, res, "Element should be incremented by 1 after mapping")
}

func TestFilter(t *testing.T) {
	isEqual := func(e int) bool {
		return (e%2 == 0)
	}
	res := Filter(isEqual)([]int{1, 2, 3, 4, 5, 6})

	assert.Equal(t, []int{2, 4, 6}, res, "Filter should filter out odd numbers")
}

func TestWindowed(t *testing.T) {
	res := Windowed([]int{1, 2, 3, 4, 5}, 4)

	assert.Equal(t, [][]int{{1, 2, 3, 4}, {2, 3, 4, 5}}, res)
}

func TestWindowedTooSmall(t *testing.T) {
	res := Windowed([]int{1}, 4)

	assert.Equal(t, [][]int{}, res)
}

func TestWindowedUneven(t *testing.T) {
	res := Windowed([]int{1, 2, 3, 4, 5}, 3)

	assert.Equal(t, [][]int{{1, 2, 3}, {2, 3, 4}, {3, 4, 5}}, res)
}

func TestMakeRange(t *testing.T) {
	r1 := MakeRange(0, 4)
	r2 := MakeRange(4, 0)

	assert.Equal(t, []int{0, 1, 2, 3, 4}, r1)
	assert.Equal(t, []int{4, 3, 2, 1, 0}, r2)
}

func TestReverse(t *testing.T) {
	r1 := Reverse([]int{1, 2, 3})

	assert.Equal(t, []int{3, 2, 1}, r1)
}
