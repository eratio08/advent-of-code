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
	ores   [4]uint
	robots [4]uint
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

func (this State) addOres() State {
	for i, ore := range this.robots {
		this.ores[i] += ore
	}

	return this
}

func (this State) reduceTime() State {
	this.time -= 1
	return this
}

func (this *blueprint) qualityScore() uint {
	cache := map[State]uint{}

	addOres := func(a [4]uint, b [4]uint) [4]uint {
		for i, o := range b {
			a[i] += o
		}
		return a
	}

	var search func(uint, [4]uint, [4]uint) uint
	search = func(time uint, ores [4]uint, robots [4]uint) uint {
		if time <= 0 {
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
				newRobots := robots
				newRobots[3] += 1
				geodes := search(time-1, addOres(reducedOres, collectedOres), newRobots)
				maxGeodes = helpers.MaxUint(maxGeodes, geodes)
			}

			cache[key] = maxGeodes
		}

		return cache[key]
	}

	return search(24, [4]uint{0, 0, 0, 0}, [4]uint{1, 0, 0, 0})
}

func part1(lines []string, pattern *regexp.Regexp) (out uint) {
	blueprints := parseBlueprints(lines, pattern)
	for _, bp := range blueprints {
		out += bp.id * bp.qualityScore()
	}

	return 0
}

func main() {
	pattern := regexp.MustCompile(`Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian.`)
	lines := helpers.ReadLines("test")
	fmt.Println(part1(lines, pattern))

}
