open Aoc2015

let d1 =
  print_endline "## Day 01 ##";
  let input = Input.read_all "input/d01" in
  let floor = D01.move input in
  Int.to_string floor |> print_endline;

  let position = D01.detect_cellar input in
  Int.to_string position |> print_endline;
  ()

let d2 =
  print_endline "## Day 02 ##";
  let input = Input.read_lines "input/d02" in
  let paper = D02.determine_paper input in
  Int.to_string paper |> print_endline;

  let ribbon = D02.determine_ribbon input in
  Int.to_string ribbon |> print_endline;
  ()

let d3 =
  print_endline "## Day 03 ##";
  let input = Input.read_all "input/d03" in
  let houses = D03.deliver_packages input in
  Int.to_string houses |> print_endline;

  let other_houses = D03.deliver_packages_with_robo input in
  Int.to_string other_houses |> print_endline;

  ()

let () =
  d1;
  d2;
  d3;

  ()
