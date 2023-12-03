open Core

type position = int * int

type number =
  { positions : position list
  ; value : int
  }

let number_of start y cs : number =
  let lenght = List.length cs in
  let value = List.rev cs |> String.of_list |> Int.of_string in
  let positions =
    List.range ~stop:`exclusive start (start + lenght) |> List.map ~f:(fun x -> x, y)
  in
  { positions; value }
;;

type symbol = { position : position }

let find_symbol y line : symbol list =
  line
  |> String.to_list
  |> List.foldi ~init:[] ~f:(fun x acc c ->
    if Char.is_alpha c || Char.is_digit c || Char.equal c '.'
    then acc
    else { position = x, y (* ; value = c *) } :: acc)
;;

let find_numbers y line : number list =
  let rec loop pos cur res = function
    | [] ->
      if List.length cur > 0
      then (
        let start = pos - List.length cur in
        let number = number_of start y cur in
        number :: res)
      else res
    | h :: t ->
      if Char.is_digit h
      then
        if List.length cur = 0
        then loop (pos + 1) [ h ] res t
        else loop (pos + 1) (h :: cur) res t
      else if List.length cur = 0
      then loop (pos + 1) cur res t
      else (
        let start = pos - List.length cur in
        let number = number_of start y cur in
        loop (pos + 1) [] (number :: res) t)
  in
  String.to_list line |> loop 0 [] []
;;

let adjacent_pos = [ -1, -1; 0, -1; 1, -1; -1, 0; 1, 0; -1, 1; 0, 1; 1, 1 ]

let is_adjacent p1 p2 : bool =
  let x1, y1 = p1 in
  let x2, y2 = p2 in
  let ps = adjacent_pos |> List.map ~f:(fun (x, y) -> x1 + x, y1 + y) in
  ps |> List.exists ~f:(fun (x, y) -> x = x2 && y = y2)
;;

let is_part (number : number) (symbol : symbol) : bool =
  let is_part =
    number.positions |> List.exists ~f:(fun p -> is_adjacent symbol.position p)
  in
  is_part
;;

let find_symbols_numbers lines =
  lines
  |> List.foldi ~init:([], []) ~f:(fun y ls line ->
    let symbols, numbers = ls in
    let syms = find_symbol y line in
    let nums = find_numbers y line in
    List.append symbols syms, List.append numbers nums)
;;

let find_parts symbols numbers =
  numbers |> List.filter ~f:(fun number -> symbols |> List.exists ~f:(is_part number))
;;

let (() : unit) =
  let lines = Advent.Input.read_lines "input/day03" in
  let symbols, numbers = find_symbols_numbers lines in
  let parts = find_parts symbols numbers in
  let sum =
    parts |> List.fold ~init:0 ~f:(fun acc (number : number) -> number.value + acc)
  in
  Fmt.pr "%d\n" sum
;;

let () =
  let lines = Advent.Input.read_lines "input/day03" in
  let symbols, numbers = find_symbols_numbers lines in
  let sum =
    symbols
    |> List.fold ~init:0 ~f:(fun acc symbol ->
      let adjavent_numbers =
        List.filter numbers ~f:(fun number -> is_part number symbol)
      in
      let is_gear = List.length adjavent_numbers = 2 in
      if is_gear
      then (
        let product = List.fold ~init:1 ~f:(fun s i -> s * i.value) adjavent_numbers in
        product + acc)
      else acc)
  in
  Fmt.pr "%d\n" sum
;;
