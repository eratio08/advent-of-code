package fp

import "fmt"

type List[A any] struct {
	head A
	tail *List[A]
}

func Cons[A any](es ...A) List[A] {
	if len(es) == 1 {
		return List[A]{head: es[0], tail: nil}
	} else {
		head, tail := es[0], es[1:]
		listTail := Cons(tail...)
		return List[A]{head: head, tail: &listTail}
	}
}

func (this List[A]) String() string {
	join := func(x A, s string) string { return fmt.Sprint(x, " ", s) }
	return fmt.Sprint("List[ ", Foldr(join)("")(&this), "]")
}

/* foldr :: Foldable t => (a -> b -> b) -> b -> t a -> b */
func Foldr[A any, B any](fn func(A, B) B) func(B) func(*List[A]) B {
	return func(b B) func(*List[A]) B {
		return func(as *List[A]) B {
			switch as {
			case nil:
				return b
			default:
				return fn(as.head, Foldr(fn)(b)(as.tail))
			}
		}
	}
}

/* foldl :: Foldable t => (b -> a -> b) -> b -> t a -> b */
func Foldl[A any, B any](fn func(B, A) B) func(B) func(*List[A]) B {
	return func(b B) func(*List[A]) B {
		return func(as *List[A]) B {
			switch as {
			case nil:
				return b
			default:
				return Foldl(fn)(fn(b, as.head))(as.tail)
			}
		}
	}
}

func Length[A any](as *List[A]) int {
	count := func(a A, c int) int {
		return c + 1
	}
	return Foldr(count)(0)(as)
}

// func Map[A any, B any](fn func(A) B) func(*List[A]) List[B] {
// 	return func(as *List[A]) List[B] {
// 		comp := func(a A, b List[B]) List[B] {
// 			return List[B]{
// 				head: fn(a),
// 				tail: &b,
// 			}
// 		}
// 		return Foldr(comp)(nil)(as)
// 	}
// }
