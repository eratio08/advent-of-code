package main

import (
	"aoc2022/helpers"
	"fmt"
	"strings"
)

type Packet struct {
	value    int
	children []*Packet
	parent   *Packet
}

func (this Packet) String() string {
	if len(this.children) == 0 {
		return fmt.Sprint(this.value)
	}

	children := helpers.Map(func(p *Packet) string { return fmt.Sprint(p) })(this.children)
	return fmt.Sprintf("[%v]", strings.Join(children, ", "))
}

func parsePacket(chars string) Packet {
	root := Packet{-1, []*Packet{}, nil}
	current := &root
	var num string
	for _, c := range chars {
		switch c {
		case '[':
			newPacket := &Packet{-1, []*Packet{}, current}
			current.children = append(current.children, newPacket)
			current = newPacket
		case ']':
			current = current.parent
		case ',':
			var i int
			if len(num) > 0 {
				i = helpers.ToInt(num)
			} else {
				i = -1
			}
			current.children = append(current.children, &Packet{i, []*Packet{}, current})
			num = ""
		default:
			num += string(c)
		}
	}

	return *root.children[0]
}

func parsePackets(pair string) (left Packet, right Packet) {
	packets := strings.Split(pair, "\n")
	left = parsePacket(packets[0])
	right = parsePacket(packets[1])

	return left, right
}

func compare(left Packet, right Packet) int {
	// fmt.Printf("Compare %v vs %v\n", left, right)

	switch {
	/* both leafs */
	case len(left.children) == 0 && len(right.children) == 0:
		if left.value > right.value {
			return -1
		} else if left.value == right.value {
			return 0
		} else {
			return 1
		}

	/* left leaf */
	case left.value >= 0:
		return compare(Packet{-1, []*Packet{&left}, nil}, right)

	/* right leaf */
	case right.value >= 0:
		return compare(left, Packet{-1, []*Packet{&right}, nil})

	default: /* both nodes */
		var i int
		for i = 0; i < len(left.children) && i < len(right.children); i++ {
			comp := compare(*left.children[i], *right.children[i])
			if comp != 0 {
				return comp
			}
		}
		if i < len(left.children) {
			return -1
		} else if i < len(right.children) {
			return 1
		}
	}

	return 0
}

func part1(content string) int {
	pairs := strings.Split(content, "\n\n")
	res := 0
	for i, pair := range pairs {
		left, right := parsePackets(pair)
		fmt.Println(left)
		fmt.Println(right)
		ord := compare(left, right)
		fmt.Println(ord)

		if ord == 1 {
			res += i + 1
		}
	}

	return res
}

func main() {
	test := helpers.ReadFile("test")
	input := helpers.ReadFile("input")
	fmt.Println(part1(test))
	fmt.Println(part1(input))
}
