package main

import (
	"aoc2022/helpers"
	"fmt"
)

func main() {
	lines := helpers.ReadLines("input")
	fmt.Println(part1(lines))
}

func part1(lines []string) snafu {
	snafus := helpers.Map(func(s string) int { return snafu(s).toInt() })(lines)
	sum := helpers.Foldr(func(i int, acc int) int { return acc + i })(0)(snafus)

	return fromInt(sum)
}

type snafu string

func (s snafu) toInt() (out int) {
	revSnafu := helpers.ReverseStr(string(s))
	for i, n := range revSnafu {
		l := 0
		switch str := string(n); str {
		case "-":
			l = -1
		case "=":
			l = -2
		default:
			l = helpers.ToInt(str)
		}
		out += (helpers.PowInt(5, i)) * l
	}

	fmt.Println("toInt", s, "=", out)
	return out
}

func fromInt(i int) (out snafu) {
	SNAFU_NUMBERS := [5]string{"0", "1", "2", "=", "-"}
	if i == 0 {
		return ""
	}

	rem := i % 5
	out = snafu(fmt.Sprintf("%v%v", out, fromInt((i+2)/5)))
	out = snafu(fmt.Sprintf("%v%v", out, SNAFU_NUMBERS[rem]))

	return out
}
