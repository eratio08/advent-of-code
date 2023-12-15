open Core

let hash s =
  String.strip ~drop:Char.is_whitespace s
  |> String.fold ~init:0 ~f:(fun acc c ->
    Char.to_int c |> ( + ) acc |> ( * ) 17 |> fun n -> Int.rem n 256)
;;

let () =
  Fmt.pr "HASH=%d\n" (hash "HASH");
  let lines = Advent.Input.read_all "input/day15" in
  let instructions = String.split lines ~on:',' in
  let n = List.fold instructions ~init:0 ~f:(fun acc s -> hash s + acc) in
  Fmt.pr "%d\n" n;
  ()
;;
