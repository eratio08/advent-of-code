open Aoc2015

(* let d1 = *)
(*   print_endline "## Day 01 ##"; *)
(*   let input = Input.read_all "input/d01" in *)
(*   let floor = D01.move input in *)
(*   Int.to_string floor |> print_endline; *)
(*   let position = D01.detect_cellar input in *)
(*   Int.to_string position |> print_endline; *)
(*   () *)
(* ;; *)
(***)
(* let d2 = *)
(*   print_endline "## Day 02 ##"; *)
(*   let input = Input.read_lines "input/d02" in *)
(*   let paper = D02.determine_paper input in *)
(*   Int.to_string paper |> print_endline; *)
(*   let ribbon = D02.determine_ribbon input in *)
(*   Int.to_string ribbon |> print_endline; *)
(*   () *)
(* ;; *)
(***)
(* let d3 = *)
(*   print_endline "## Day 03 ##"; *)
(*   let input = Input.read_all "input/d03" in *)
(*   let houses = D03.deliver_packages input in *)
(*   Int.to_string houses |> print_endline; *)
(*   let other_houses = D03.deliver_packages_with_robo input in *)
(*   Int.to_string other_houses |> print_endline; *)
(*   () *)
(* ;; *)
(***)
(* let d4 = *)
(*   print_endline "## Day 04 ##"; *)
(*   let num = D04.mine "bgvyzdsv" 5 in *)
(*   Int.to_string num |> print_endline; *)
(*   let num = D04.mine "bgvyzdsv" 6 in *)
(*   Int.to_string num |> print_endline; *)
(*   () *)
(* ;; *)

(* let d5 = *)
(*   print_endline "## Day 05 ##"; *)
(*   let input = Input.read_lines "input/d05" in *)
(*   let num = D05.count_nice input in *)
(*   Int.to_string num |> print_endline; *)
(*   D05.count_nice' input |> Int.to_string |> print_endline; *)
(*   () *)
(* ;; *)

let d6 =
  print_endline "## Day 06 ##";
  let input = Input.read_lines "input/d06" in
  let lit_lights = D06.lit_lights input in
  lit_lights |> Int.to_string |> print_endline;
  let lit_lights = D06.lit_lights' input in
  lit_lights |> Int.to_string |> print_endline;
;;

let () =
  (* d1; *)
  (* d2; *)
  (* d3; *)
  (* d4; *)
  (* d5; *)
  d6;
  ()
;;
