package main

import (
	"aoc2022/helpers"
	"fmt"
	"regexp"
)

type robot struct {
	ore, clay, obsidian uint
}

type blueprint struct {
	id       uint
	ore      robot
	clay     robot
	obsidian robot
	geode    robot
}

type State struct {
	time   uint
	ores   [3]uint
	robots [3]uint
}

func parse(line string, pattern *regexp.Regexp) blueprint {
	matches := pattern.FindStringSubmatch(line)
	id := helpers.ToUint(matches[1])
	oreRobotOreCost := helpers.ToUint(matches[2])
	clayRobotOreCost := helpers.ToUint(matches[3])
	obsidianOreCost := helpers.ToUint(matches[4])
	obsidianClayCost := helpers.ToUint(matches[5])
	geodeOreCost := helpers.ToUint(matches[6])
	geodeObsidianCost := helpers.ToUint(matches[7])

	oreRobot := robot{oreRobotOreCost, 0, 0}
	clayRobot := robot{clayRobotOreCost, 0, 0}
	obsidianRobot := robot{obsidianOreCost, obsidianClayCost, 0}
	geodenRobot := robot{geodeOreCost, 0, geodeObsidianCost}

	return blueprint{id, oreRobot, clayRobot, obsidianRobot, geodenRobot}
}

func parseBlueprints(lines []string, pattern *regexp.Regexp) []blueprint {
	return helpers.Map(func(line string) blueprint { return parse(line, pattern) })(lines)
}

func (this State) reduceTime() State {
	this.time -= 1
	return this
}

func (this *blueprint) qualityScore(time uint) uint {
	cache := map[State]uint{}

	addOres := func(a [3]uint, b [3]uint) [3]uint {
		for i, o := range b {
			a[i] += o
		}
		return a
	}

	var search func(uint, [3]uint, [3]uint) uint
	search = func(time uint, ores [3]uint, robots [3]uint) uint {
		if time == 0 {
			return 0
		}

		key := State{time, ores, robots}
		_, exists := cache[key]
		if !exists {
			collectedOres := robots
			maxGeodes := search(time-1, addOres(ores, collectedOres), robots)

			if ores[0] >= this.ore.ore {
				reducedOres := ores
				reducedOres[0] -= this.ore.ore
				newRobots := robots
				newRobots[0] += 1
				geodes := search(time-1, addOres(reducedOres, collectedOres), newRobots)
				maxGeodes = helpers.MaxUint(maxGeodes, geodes)
			}

			if ores[0] >= this.clay.ore {
				reducedOres := ores
				reducedOres[0] -= this.clay.ore
				newRobots := robots
				newRobots[1] += 1
				geodes := search(time-1, addOres(reducedOres, collectedOres), newRobots)
				maxGeodes = helpers.MaxUint(maxGeodes, geodes)
			}

			if ores[0] >= this.obsidian.ore && ores[1] >= this.obsidian.clay {
				reducedOres := ores
				reducedOres[0] -= this.obsidian.ore
				reducedOres[1] -= this.obsidian.clay
				newRobots := robots
				newRobots[2] += 1
				geodes := search(time-1, addOres(reducedOres, collectedOres), newRobots)
				maxGeodes = helpers.MaxUint(maxGeodes, geodes)
			}

			if ores[0] >= this.geode.ore && ores[2] >= this.geode.obsidian {
				reducedOres := ores
				reducedOres[0] -= this.geode.ore
				reducedOres[2] -= this.geode.obsidian
				geodes := search(time-1, addOres(reducedOres, collectedOres), robots)
				maxGeodes = helpers.MaxUint(maxGeodes, geodes+time-1)
			}

			cache[key] = maxGeodes
		}

		return cache[key]
	}

	return search(time, [3]uint{0, 0, 0}, [3]uint{1, 0, 0})
}

func part1(lines []string, pattern *regexp.Regexp) (out uint) {
	blueprints := parseBlueprints(lines, pattern)
	for _, bp := range blueprints {
		out += bp.id * bp.qualityScore(24)
		fmt.Println("Out", out)
	}

	return out
}

func part2(lines []string, pattern *regexp.Regexp) (out uint) {
	blueprints := parseBlueprints(lines, pattern)
	for _, bp := range blueprints[:1] {
		out *= bp.qualityScore(32)
		fmt.Println("Out", out)
	}

	return out
}

func main() {
	pattern := regexp.MustCompile(`Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian.`)
	lines := helpers.ReadLines("input")
	// fmt.Println(part1(lines, pattern))
	fmt.Println(part2(lines, pattern))

}
