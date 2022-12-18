package main

/* This is not my solution! This is a port of https://github.com/remmycat/advent-of-code-rs/blob/main/2022/days/15-beacon-exclusion-zone/src/lib.rs */

import (
	"aoc2022/helpers"
	"fmt"
	"regexp"
)

type pos struct {
	x, y int
}

type intRange [2]int

type intRangeSet struct {
	min, max int
	ranges   map[intRange]bool
}

func (this *intRangeSet) add(r intRange) {
	start := r[0]
	end := r[1]
	if start < this.min {
		this.min = start
	}
	if end > this.max {
		this.max = end
	}
	this.ranges[r] = true
}

func (this intRangeSet) len() int {
	return helpers.AbsDiff(this.max, this.min)
}

type diagonalPos struct {
	x, y int
}

func (this diagonalPos) intoPos() pos {
	return pos{
		x: (this.x - this.y) / 2,
		y: (this.x + this.y) / 2,
	}
}

func (this pos) intoDiagonalPos() diagonalPos {
	return diagonalPos{
		x: this.x + this.y,
		y: -this.x + this.y,
	}
}

func (this *pos) distance(other *pos) uint {
	/* taxicab distance |x1 - x2| + |y1 - y2| */
	return uint(helpers.AbsDiff(this.x, other.x) + helpers.AbsDiff(this.y, other.y))
}

type diamond struct {
	/* top-left */
	top diagonalPos
	/* bottom-right */
	bottom diagonalPos
}

func newDiamond(sensor *sensor) diamond {
	return diamond{
		top: pos{
			x: sensor.location.x,
			y: sensor.location.y - int(sensor.distance),
		}.intoDiagonalPos(),
		bottom: pos{
			x: sensor.location.x,
			y: sensor.location.y + int(sensor.distance),
		}.intoDiagonalPos(),
	}
}

type sensor struct {
	location pos
	beacon   pos
	distance uint
}

func (this *sensor) rangesAtY(y int) []intRange {
	diffX := int(this.distance) - helpers.AbsDiff(this.location.y, y)
	r := [2]int{this.location.x - diffX, this.location.x + diffX}

	if this.beacon.y == y {
		r2 := []intRange{{r[0], this.beacon.x - 1}, {this.beacon.x + 1, r[1]}}
		r2 = helpers.Filter(func(r intRange) bool { return r[1] >= r[0] })(r2)
		return r2
	} else {
		return []intRange{r}
	}
}

func parseSensors(lines []string) (out []sensor) {
	matcher := regexp.MustCompile(`Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)`)
	for _, line := range lines {
		if line == "" {
			continue
		}
		matches := matcher.FindStringSubmatch(line)
		sensorX := helpers.ToInt(matches[1])
		sensorY := helpers.ToInt(matches[2])
		beaconX := helpers.ToInt(matches[3])
		beaconY := helpers.ToInt(matches[4])
		location := pos{sensorX, sensorY}
		beacon := pos{beaconX, beaconY}
		out = append(out, sensor{
			location: location,
			beacon:   beacon,
			distance: location.distance(&beacon),
		})
	}

	return out
}

func part1(lines []string, yCheck int) int {
	sensors := parseSensors(lines)
	intersectingYCheck := helpers.Filter(func(s sensor) bool { return helpers.AbsDiff(s.location.y, yCheck) <= int(s.distance) })(sensors)
	ranges := helpers.FlatMap(func(s sensor) []intRange { return s.rangesAtY(yCheck) })(intersectingYCheck)
	rangeSet := helpers.Foldr(func(r intRange, set intRangeSet) intRangeSet {
		set.add(r)
		return set
	})(intRangeSet{0, 0, map[intRange]bool{}})(ranges)

	return rangeSet.len()
}

func (this *pos) tuningFrequency() uint {
	return uint(this.x)*4_000_000 + uint(this.y)
}

func (this diamond) corners() []pos {
	return []pos{
		diagonalPos{this.top.x, this.bottom.y}.intoPos(),
		diagonalPos{this.bottom.x, this.top.y}.intoPos(),
		this.top.intoPos(),
		this.bottom.intoPos(),
	}
}

func (this *diamond) edgeIntersections(other *diamond) []pos {
	xStart := this.top.x - 1
	xEnd := this.bottom.x + 1
	otherXStart := other.top.x - 1
	otherXEnd := other.bottom.x + 1

	yStart := this.top.y - 1
	yEnd := this.bottom.y + 1
	otherYStart := other.top.y - 1
	otherYEnd := other.bottom.y + 1

	if xEnd < otherXStart || xStart > otherXEnd || yEnd < otherYStart || yStart > otherYEnd {
		return []pos{}
	} else {
		return diamond{
			top: diagonalPos{
				x: helpers.Max(xStart, otherXStart),
				y: helpers.Max(yStart, otherYStart),
			},
			bottom: diagonalPos{
				x: helpers.Min(yStart, otherYStart),
				y: helpers.Min(yEnd, otherYEnd),
			},
		}.corners()
	}
}

func part2(lines []string, searchScope int) int {
	sensors := parseSensors(lines)
	diamonds := helpers.Map(func(s sensor) diamond { return newDiamond(&s) })(sensors)
	searchRange := helpers.MakeRange(0, searchScope)

	edges := []pos{}
	for i, d1 := range diamonds {
		dr := diamonds[i+1:]
		for _, d2 := range dr {
			corners := d1.edgeIntersections(&d2)
			if len(corners) > 0 {
				edges = append(edges, corners...)
			}
		}
	}
	edgesInRange := helpers.Filter(func(p pos) bool { return helpers.Contains(p.x, searchRange) && helpers.Contains(p.y, searchRange) })(edges)
	corners := []pos{{0, 0}, {0, searchScope}, {searchScope, 0}, {searchScope, searchScope}}
	edgesWithCorners := append(edgesInRange, corners...)
	unmatched := helpers.Filter(func(p pos) bool {
		return helpers.All(func(s sensor) bool { return s.location.distance(&p) > s.distance })(sensors)
	})(edgesWithCorners)

	unmatchedPos := unmatched[0]

	return int(unmatchedPos.tuningFrequency())
}

func main() {
	lines := helpers.ReadLines("input")
	// fmt.Println(part1(lines, 10))
	fmt.Println(part1(lines, 2_000_000))
	// fmt.Println(part2(lines, 20))
	fmt.Println(part2(lines, 4_000_000))
}
