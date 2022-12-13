package fp

import "fmt"

type (
	List[A any] interface {
		Head() A
		Tail() List[A]
	}
	Cons[A any] struct {
		head A
		tail List[A]
	}
	Nil[A any] struct{}
)

func (this *Cons[A]) Head() A {
	return this.head
}

func (this *Cons[A]) Tail() List[A] {
	return this.tail
}

func (this *Nil[A]) Head() A {
	panic("Can't call Head on Nil")
}

func (this *Nil[A]) Tail() List[A] {
	panic("Can't call Tail on Nil")
}

func NewList[A any](es ...A) List[A] {
	if len(es) == 1 {
		n := Nil[A]{}
		return Cons[A]{head: es[0], tail: n}
	} else {
		head, tail := es[0], es[1:]
		listTail := Cons(tail...)
		return List[A]{head: head, tail: &listTail}
	}
}

func (this Cons[A]) String() string {
	join := func(x A, s string) string { return fmt.Sprint(x, " ", s) }
	return fmt.Sprint("List[ ", Foldr(join)("")(&this), "]")
}

/* foldr :: Foldable t => (a -> b -> b) -> b -> t a -> b */
func Foldr[A any, B any](fn func(A, B) B) func(B) func(List[A]) B {
	return func(b B) func(List[A]) B {
		return func(as List[A]) B {
			switch l := as.(type) {
			case *Nil[A]:
				return b
			case *Cons[A]:
				return fn(l.head, Foldr(fn)(b)(l.tail))
			default:
				panic("Unknown type of List")
			}
		}
	}
}

/* foldl :: Foldable t => (b -> a -> b) -> b -> t a -> b */
func Foldl[A any, B any](fn func(B, A) B) func(B) func(List[A]) B {
	return func(b B) func(List[A]) B {
		return func(as List[A]) B {
			switch l := (as).(type) {
			case *Nil[A]:
				return b
			case *Cons[A]:
				return Foldl(fn)(fn(b, l.head))(l.tail)
			default:
				panic("Unknown type for List")
			}
		}
	}
}

func FoldRightL[A any, B any](fn func(A, B) B) func(B) func(List[A]) B {
	return func(b B) func(List[A]) B {
		return func(as List[A]) B {
			lazy := func(g func(B) B, a A) func(B) B {
				return func(b B) B {
					return g(fn(a, b))
				}
			}
			id := func(b B) B { return b }
			return Foldl(lazy)(id)(as)(b)
		}
	}
}

func Length[A any](as List[A]) int {
	count := func(a A, c int) int {
		return c + 1
	}
	return Foldr(count)(0)(as)
}

func Map[A any, B any](fn func(A) B) func(List[A]) List[B] {
	return func(as List[A]) List[B] {
		cons := func(a A, bs List[B]) List[B] {
			return &Cons[B]{
				head: fn(a),
				tail: bs,
			}
		}
		return FoldRightL(cons)(&Nil[B]{})(as)
	}
}
