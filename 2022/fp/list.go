package fp

import "fmt"

type List[A any] struct {
	head A
	tail *List[A]
}

func Cons[A any](es ...A) *List[A] {
	if len(es) == 0 {
		return nil
	} else {
		head, tail := es[0], es[1:]
		return &List[A]{head: head, tail: Cons(tail...)}
	}
}

func Foldr[A any, B any](fn func(A, B) B, y B, xs *List[A]) B {
	switch xs {
	case nil:
		return y
	default:
		return fn(xs.head, Foldr(fn, y, xs.tail))
	}
}

func (this *List[A]) String() string {
	join := func(x A, s string) string { return fmt.Sprint(x, " ", s) }
	return fmt.Sprint("List[ ", Foldr(join, "", this), "]")
}

func partial[A any, B any, C any](fn func(A, B) C, a A) func(B) C {
	return func(b B) C {
		return fn(a, b)
	}
}

func curry[A any, B any, C any](fn func(A, B) C) func(A) func(B) C {
	return func(a A) func(b B) C {
		return func(b B) C {
			return fn(a, b)
		}
	}
}

func uncurry[A any, B any, C any](fn func(A) func(B) C) func(A, B) C {
	return func(a A, b B) C {
		return fn(a)(b)
	}
}
