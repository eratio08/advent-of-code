package main

import (
	"aoc2022/helpers"
	"fmt"
)

func safeIndex(i, size int) int {
	return (i%size + size) % size
}

type num [2]int

func parse(lines []string) (out []num) {
	for i, n := range lines {
		out = append(out, num{i, helpers.ToInt(n)})
	}

	return out
}

func hasIndex(i int) func(num) bool {
	return func(n num) bool {
		return n[0] == i
	}
}

func rotate(nums []num) []num {
	for i := 0; i < len(nums); i++ {
		/* find index of entry with actual index i */
		i := helpers.IndexOf(hasIndex(i))(nums)
		n := nums[i]

		/* extract */
		before := nums[:i]
		after := nums[i+1:]
		nums = append(before, after...)

		/* insert */
		i = safeIndex(i+n[1], len(nums))
		before = nums[:i]
		after = nums[i:]
		newSection := append([]num{n}, after...)
		nums = append(before, newSection...)
	}

	return nums
}

func isFirst(n num) bool {
	return n[1] == 0
}

func decrypt(nums []num, key, times int) int {
	nums = append([]num(nil), nums...)
	for i := range nums {
		nums[i][1] *= key
	}

	for t := 0; t < times; t++ {
		nums = rotate(nums)
	}

	indexFirst := helpers.IndexOf(isFirst)(nums)
	i1000 := safeIndex(indexFirst+1000, len(nums))
	i2000 := safeIndex(indexFirst+2000, len(nums))
	i3000 := safeIndex(indexFirst+3000, len(nums))

	return nums[i1000][1] + nums[i2000][1] + nums[i3000][1]
}

func part1(lines []string) int {
	nums := parse(lines)

	return decrypt(nums, 1, 1)
}

func part2(lines []string) int {
	nums := parse(lines)

	return decrypt(nums, 811589153, 10)
}

func main() {
	lines := helpers.ReadLines("input")
	fmt.Println(part1(lines))
	fmt.Println(part2(lines))
}
