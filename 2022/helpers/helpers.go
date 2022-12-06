package helpers

import (
	"log"
	"os"
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

func Foldr[I any, O any](a O, l []I, fn func(int, O, I) O) O {
	for i, e := range l {
		a = fn(i, a, e)
	}

	return a
}

func Map[I any, O any](l []I, fn func(int, I) O) []O {
	return Foldr(make([]O, 0, len(l)), l, func(i int, a []O, l I) []O {
		a = append(a, fn(i, l))
		return a
	})
}

func Filter[I any](l []I, p func(int, I) bool) []I {
	return Foldr(make([]I, 0, len(l)), l, func(i int, a []I, l I) []I {
		if p(i, l) {
			a = append(a, l)
		}
		return a
	})
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
