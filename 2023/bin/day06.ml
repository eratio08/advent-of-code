open Core
(*
   x^2 + (- b) x + c

   x = - ( - b) +- sqrt (b ^ 2 - 4 c) / 2
*)

module Race = struct
  type t =
    { time : int
    ; distance : int
    }

  let parse lines =
    let line_to_nums line =
      String.to_list line
      |> List.drop_while ~f:(fun c -> Char.is_digit c |> not)
      |> String.of_list
      |> String.split ~on:' '
      |> List.filter ~f:(fun x -> String.is_empty x |> not)
      |> List.map ~f:Int.of_string
    in
    let times = List.nth_exn lines 0 |> line_to_nums in
    let distances = List.nth_exn lines 1 |> line_to_nums in
    List.zip_exn times distances
    |> List.map ~f:(fun (time, distance) -> { time; distance })
  ;;

  let find_bounds { time; distance } =
    let distance = Float.of_int distance in
    let time = Float.of_int time in
    let b1 = 0.5 *. (time +. Float.sqrt ((time *. time) -. (4.0 *. distance))) in
    let b2 = 0.5 *. (time -. Float.sqrt ((time *. time) -. (4.0 *. distance))) in
    if Float.compare b1 b2 < 0
    then Int.of_float (b1 +. 1.0), Int.of_float b2
    else Int.of_float (b2 +. 1.0), Int.of_float b1
  ;;

  let is_further b { time; distance } = (time - b) * b > distance

  let possible_wins r =
    let b1, b2 = find_bounds r in
    let b1 = if is_further b1 r then b1 else b1 + 1 in
    let b2 = if is_further b2 r then b2 else b2 - 1 in
    Int.abs (b1 - b2) + 1
  ;;
end

let () =
  let lines = Advent.Input.read_lines "input/day06" in
  let races = Race.parse lines in
  let wins =
    races
    |> List.fold ~init:1 ~f:(fun acc r ->
      let wins = Race.possible_wins r in
      wins * acc)
  in
  Fmt.pr "%d\n" wins
;;
