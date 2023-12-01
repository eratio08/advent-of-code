open Core

let take_first_last line = Advent.String.first line ^ Advent.String.last line
let take_digitis line = String.filter ~f:Char.is_digit line

let part1 : int =
  Advent.Input.read_lines "input/day01"
  |> List.map ~f:take_digitis
  |> List.map ~f:take_first_last
  |> List.map ~f:Int.of_string
  |> List.fold ~init:0 ~f:Int.( + )
;;

Fmt.pr "%d\n" part1

let cases =
  [ "one", "1"
  ; "two", "2"
  ; "three", "3"
  ; "four", "4"
  ; "five", "5"
  ; "six", "6"
  ; "seven", "7"
  ; "eight", "8"
  ; "nine", "9"
  ; "1", "1"
  ; "2", "2"
  ; "3", "3"
  ; "4", "4"
  ; "5", "5"
  ; "6", "6"
  ; "7", "7"
  ; "8", "8"
  ; "9", "9"
  ]
;;

let map_to_digit str pos : string option =
  cases
  |> List.find_map ~f:(fun (substr, value) ->
    match String.substr_index ~pos str ~pattern:substr with
    | Some matched when matched = pos -> Some value
    | _ -> None)
;;

let first_match str : string =
  let map_to_number = map_to_digit str in
  List.range 0 (String.length str) |> List.find_map ~f:map_to_number |> Option.value_exn
;;

let last_match str =
  let map_to_number = map_to_digit str in
  List.range ~stride:(-1) ~stop:`inclusive (String.length str) 0
  |> List.find_map ~f:map_to_number
  |> Option.value_exn
;;

(*
   Taken from https://github.com/tjdevries/advent_of_code/blob/master/2023/bin/day01.ml

   Lessons Learned
   * `List.find_map` can early terminate on some
   * `List.range` very handy, set stride negative to invert the range
*)
let part2 =
  let lines = Advent.Input.read_lines "input/day01" in
  List.fold lines ~init:0 ~f:(fun acc line ->
    let first_num = first_match line in
    let second_num = last_match line in
    let number = Fmt.str "%s%s" first_num second_num in
    let number = Int.of_string number in
    acc + number)
;;

Fmt.pr "%d\n" part2
