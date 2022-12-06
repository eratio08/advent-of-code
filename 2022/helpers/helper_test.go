package helpers

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestFold(t *testing.T) {
	sum := Foldr(0, []int{1, 2, 3, 4, 5}, func(i int, a int, e int) int {
		return a + e
	})

	assert.Equal(t, 15, sum, "Sum after foldr should be 15")
}

func TestMap(t *testing.T) {
	res := Map([]int{1, 2, 3, 4, 5}, func(i int, e int) int {
		return e + 1
	})

	assert.Equal(t, []int{2, 3, 4, 5, 6}, res, "Element should be incremented by 1 after mapping")
}

func TestFilter(t *testing.T) {
	res := Filter([]int{1, 2, 3, 4, 5, 6}, func(i int, e int) bool {
		return (e%2 == 0)
	})

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
