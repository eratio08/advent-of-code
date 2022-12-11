package main

import (
	"aoc2022/helpers"
	"fmt"
	"sort"
	"strings"
)

type (
	Monkey struct {
		items []uint64
		op    func(uint64) uint64
		test  func(uint64) int
		count uint64
		d     uint64
	}
)

func add(a uint64) func(uint64) uint64 {
	return func(b uint64) uint64 {
		// fmt.Printf("Worry level increases by %v to %v.\n", a, a+b)
		return a + b
	}
}

func mult(a uint64) func(uint64) uint64 {
	return func(b uint64) uint64 {
		// fmt.Printf("Worry level is multiplied by %v to %v.\n", a, a*b)
		return a * b
	}
}

func pow(a uint64) uint64 {
	// fmt.Printf("Worry level is multiplied by %v to %v.\n", a, a*a)
	return a * a
}

func test(d uint64, t int, f int) func(uint64) int {
	return func(i uint64) int {
		if i%d == 0 {
			// fmt.Printf("Current worry level is divisible by %v.\n", d)
			return t
		} else {
			// fmt.Printf("Current worry level is not divisible by %v.\n", d)
			return f
		}
	}
}

func parseMonkey(content string) Monkey {
	lines := strings.Split(content, "\n")

	items := []uint64{}
	var op func(uint64) uint64
	var testDivisor uint64
	var testTrue int
	var testFalse int
	for i, line := range lines[1:] {
		parts := strings.Split(line, ":")
		stmt := strings.Trim(parts[1], " ")
		switch i {
		case 0:
			items = helpers.Map(func(s string) uint64 { return uint64(helpers.ToInt(s)) })(strings.Split(stmt, ", "))
		case 1:
			opStr := strings.SplitAfter(stmt, "new = old ")[1]
			parts := strings.Split(opStr, " ")
			operand := parts[0]
			value := parts[1]
			switch operand {
			case "*":
				if value == "old" {
					op = pow
				} else {
					op = mult(uint64(helpers.ToInt(value)))
				}
			case "+":
				op = add(uint64(helpers.ToInt(value)))
			}
		case 2:
			d := strings.SplitAfter(stmt, "divisible by ")[1]
			testDivisor = uint64(helpers.ToInt(d))
		case 3:
			n := strings.SplitAfter(stmt, "throw to monkey ")[1]
			testTrue = helpers.ToInt(n)
		case 4:
			n := strings.SplitAfter(stmt, "throw to monkey ")[1]
			testFalse = helpers.ToInt(n)
		}
	}

	return Monkey{
		items: items,
		op:    op,
		test:  test(testDivisor, testTrue, testFalse),
		d:     testDivisor,
	}
}

func parse(content string) []Monkey {
	monkeyLines := strings.Split(content, "\n\n")

	return helpers.Map(parseMonkey)(monkeyLines)
}

func turn(monkey *Monkey, monkeys []Monkey, lcm uint64) Monkey {
	for _, item := range monkey.items {
		// fmt.Printf("Monkey inspects an item with a worry level of %v.\n", item)
		newScore := monkey.op(item)
		if lcm == 0 {
			newScore = newScore / 3
			// fmt.Printf("Monkey gets bored with item. Worry level is divided by 3 to %v.\n", lcm)
		} else {
			newScore = newScore % lcm
		}
		targetMonkey := monkey.test(newScore)
		// fmt.Printf("Item with worry level %v is thrown to monkey %v.\n", newScore, targetMonkey)
		monkeys[targetMonkey].items = append(monkeys[targetMonkey].items, newScore)
		monkey.items = monkey.items[1:]
		monkey.count += 1
	}

	return *monkey
}

func round(monkeys []Monkey, lcm uint64) {
	for i, monkey := range monkeys {
		monkey = turn(&monkey, monkeys, lcm)
		monkeys[i] = monkey
	}
}

func runRound(n int, lcm uint64, monkeys []Monkey) {
	for i := 0; i < n; i++ {
		round(monkeys, lcm)
		// fmt.Printf("After round %v, the monkeys are holding items with these worry levels\n", i+1)
		// for i, m := range monkeys {
		// 	fmt.Printf("Monkey %v: %v (%v)\n", i, strings.Join(helpers.Map(func(x uint64) string { return fmt.Sprint(x) })(m.items), ", "), m.count)
		// }
	}
}

func calcMonkeyBusiness(monkeys []Monkey) uint64 {
	sort.Slice(monkeys, func(i, j int) bool {
		return monkeys[i].count < monkeys[j].count
	})
	top1 := monkeys[len(monkeys)-1]
	top2 := monkeys[len(monkeys)-2]
	return top1.count * top2.count
}

func part1(content string) uint64 {
	monkeys := parse(content)

	runRound(20, 0, monkeys)
	return calcMonkeyBusiness(monkeys)
}

func euklid(a uint64, b uint64) uint64 {
	if b == 0 {
		return a
	} else {
		return euklid(b, a%b)
	}
}

func lcm(a uint64, b uint64) uint64 {
	gcd := euklid(a, b)
	return b * (a / gcd)
}

func part2(content string) uint64 {
	monkeys := parse(content)

	lcm := helpers.Foldr(func(m Monkey, acc uint64) uint64 {
		return lcm(acc, m.d)
	})(1)(monkeys)

	runRound(10_000, lcm, monkeys)
	return calcMonkeyBusiness(monkeys)
}

func main() {
	content := helpers.ReadFile("input")
	// fmt.Println(part1(content))
	fmt.Println(part2(content))

}
