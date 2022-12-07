package helpers

import (
	"log"
	"os"
	"strconv"
	"strings"
)

func ReadFile(input string) string {
	fileContent, err := os.ReadFile(input)
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}

	return string(fileContent)
}

func ReadLines(input string) []string {
	content := ReadFile(input)
	lines := strings.Split(content, "\n")
	return lines[:len(lines)-1] // drop empty last line
}

func Foldr[A any, B any](f func(A, B) B) func(B) func([]A) B {
	return func(b B) func([]A) B {
		return func(as []A) (out B) {
			out = b
			for _, a := range as {
				out = f(a, out)
			}
			return out
		}
	}
}

func Map[A any, B any](f func(A) B) func([]A) []B {
	return func(as []A) (out []B) {
		merge := func(a A, b []B) []B {
			return append(b, f(a))
		}
		return Foldr(merge)(out)(as)
	}
}

func Filter[A any](p func(A) bool) func([]A) []A {
	return func(as []A) (out []A) {
		filter := func(a A, res []A) []A {
			if p(a) {
				return append(res, a)
			}
			return res
		}
		return Foldr(filter)(out)(as)
	}
}

func Sum(is []int) int {
	sum := func(i int, s int) int {
		return s + i
	}
	return Foldr(sum)(0)(is)
}

func Values[K comparable, V any](m map[K]V) (out []V) {
	for _, v := range m {
		out = append(out, v)
	}

	return out
}

func ToInt(s string) int {
	val, err := strconv.Atoi(s)
	if err != nil {
		panic(err)
	}

	return val
}

func TakeWhile[I any](l []I, p func(i int, e I) bool) []I {
	res := make([]I, 0, cap(l))
	for i, e := range l {
		if !p(i, e) {
			break
		}

		res = append(res, e)
	}

	return res
}

func Take[I any](l []I, n int) ([]I, []I) {
	return l[:n], l[n:]
}

func Drop[I any](l []I, n int) []I {
	return l[len(l)-n:]
}

func Windowed[I any](l []I, n int) [][]I {
	res := make([][]I, 0, (len(l)/n)+1)
	for i, j := 0, n; j <= len(l); i, j = i+1, j+1 {
		window := l[i:j]
		res = append(res, window)
	}

	return res
}

type Set[E comparable] map[E]bool

func NewSet[E comparable](s []E) Set[E] {
	m := make(map[E]bool)
	for _, e := range s {
		m[e] = true
	}

	return m
}
