package fp

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
