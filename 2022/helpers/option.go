package helpers

type Option[E any] interface {
	getOrElse(func() E) E
	getOrPanic() E
	isNone() bool
	// map(func(E))
	// map()E
}

type None[E any] struct {
}

func (this *None[E]) getOrElse(fn func() E) E {
	return fn()
}

func (this *None[E]) getOrPanic() E {
	panic("No value present")
}

func (this *None[E]) isNone() bool {
	return true
}
