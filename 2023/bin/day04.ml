open Core

module Card = struct
  module IntSet = Core.Set.Make (Int)

  type t =
    { matches : int
    ; worth : int
    }

  let worth t = t.worth
  let matches t = t.matches

  let count_matches number winning =
    let winning_numbers = Set.inter number winning in
    Set.length winning_numbers
  ;;

  let calc_worth matches = if matches > 0 then Int.pow 2 (matches - 1) else 0

  (* Expecting `Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53` *)
  let of_string line : t =
    let card = line |> String.take_while ~f:(fun c -> Char.equal ':' c |> not) in
    let numbers, winning =
      String.drop_prefix line (String.length card + 1) |> String.lsplit2_exn ~on:'|'
    in
    let to_numbers str =
      str
      |> Stdlib.String.trim
      |> String.split ~on:' '
      |> List.filter ~f:(fun s -> String.is_empty s |> not)
      |> List.map ~f:Int.of_string
    in
    let numbers = to_numbers numbers |> IntSet.of_list in
    let winning = to_numbers winning |> IntSet.of_list in
    let matches = count_matches numbers winning in
    let worth = calc_worth matches in
    { matches; worth }
  ;;
end

let () =
  let lines = Advent.Input.read_lines "input/day04" in
  let cards = lines |> List.map ~f:Card.of_string in
  let sum =
    cards
    |> List.filter ~f:(fun card -> Card.worth card > 0)
    |> List.fold ~init:0 ~f:(fun sum card -> sum + Card.worth card)
  in
  Fmt.pr "%d\n" sum
;;

(*
   TODO Solve pt2 with the following logic (Go)

func Solve(lines []string) (part1, part2 int) {
	counts := make(map[int]int)
	for l, line := range lines {
		winners, inHand, _ := strings.Cut(line[9:], "|")
		copies := numberSet(inHand).Intersection(numberSet(winners)).Len()
		part1 += int(math.Pow(2, float64(copies-1)))
		part2++
		card := l + 1
		counts[card]++
		count := counts[card]
		for x := 1; x <= copies; x++ {
			counts[card+x] += count
			part2 += count
		}
		delete(counts, card)
	}
	return part1, part2
}
*)
