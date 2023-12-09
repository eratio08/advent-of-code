open Core
open Advent.Symbols

module History = struct
  let of_string = String.split ~on:' ' >> List.map ~f:Int.of_string

  module IntSet = Set.Make (Int)

  let diff t =
    let rec loop res = function
      | [] | _ :: [] -> res
      | h1 :: (h2 :: _ as t) -> loop ((h2 - h1) :: res) t
    in
    loop [] t |> List.rev
  ;;

  let diffs t =
    let rec loop res ls =
      let all_equal = IntSet.of_list ls |> Set.length |> fun length -> length = 1 in
      match all_equal with
      | true -> ls :: res
      | false ->
        let diff = diff ls in
        (* so the lowest line will be first *)
        loop (ls :: res) diff
    in
    loop [] t
  ;;

  let next t =
    let diffs = diffs t in
    let lasts =
      List.map diffs ~f:(fun diff ->
        match List.rev diff with
        | h :: _ -> h
        | _ -> failwith "should not be empty")
    in
    List.fold lasts ~init:0 ~f:( + )
  ;;

  let prev t =
    let diffs = diffs t in
    let firsts =
      List.map diffs ~f:(fun diff ->
        match diff with
        | h :: _ -> h
        | _ -> failwith "should not be empty")
    in
    List.fold firsts ~init:0 ~f:(fun acc fst -> fst - acc)
  ;;
end

let () =
  let lines = Advent.Input.read_lines "input/day09" in
  let hists = List.map lines ~f:History.of_string in
  let nexts = List.map hists ~f:History.next in
  let p1 = List.fold nexts ~init:0 ~f:( + ) in
  Fmt.pr "%d\n" p1;
  (* *)
  let prevs = List.map hists ~f:History.prev in
  let p2 = List.fold prevs ~init:0 ~f:( + ) in
  Fmt.pr "%d\n" p2;
  ()
;;
