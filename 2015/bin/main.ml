open Aoc2015

let () =
  print_endline "## Day 01 ##";
  let d01_input = Input.read_all "input/d01" in
  let floor = D01.move d01_input in
  Int.to_string floor |> print_endline;

  let position = D01.detect_cellar d01_input in
  Int.to_string position |> print_endline;

  print_endline "## Day 02 ##";
  let d02_input = Input.read_lines "input/d02" in
  let paper = D02.determine_paper d02_input in
  Int.to_string paper |> print_endline;

  let ribbon = D02.determine_ribbon d02_input in
  Int.to_string ribbon |> print_endline;

  ()
