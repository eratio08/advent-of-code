package fp

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestCons(t *testing.T) {
	xs := Cons(1, 2)
	expected := List[int]{head: 1, tail: &(List[int]{head: 2, tail: nil})}

	assert.Equal(t, fmt.Sprint(&expected), fmt.Sprint(xs), "Return the same spring representation")
	assert.Equal(t, expected.head, xs.head, "Head equals")
	assert.Equal(t, expected.tail.head, xs.tail.head, "Head of tail equals")
	// assert.Equal(t, expected.tail.tail, xs.tail.tail, "Tail of tail equals")
}

func TestFoldr(t *testing.T) {
	xs := Cons(1, 2, 3)
	add := func(a int, b int) int { return a + b }
	sum := Foldr(add, 0, xs)

	assert.Equal(t, 6, sum, "Foldr should sum up")
}
