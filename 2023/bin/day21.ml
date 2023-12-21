open Core

module Position = struct
  type t = int * int [@@deriving compare, sexp]
end

module PosSet = Set.Make (Position)

let () =
  let m =
    Advent.Input.read_lines "input/day21" |> List.map ~f:String.to_array |> List.to_array
  in
  let directions = [ 0, -1; 1, 0; 0, 1; -1, 0 ] in
  let start =
    Array.find_mapi m ~f:(fun x cols ->
      Array.find_mapi cols ~f:(fun y c -> Option.some_if (Char.equal 'S' c) (x, y)))
    |> Option.value_exn
  in
  let q = Queue.create () in
  Queue.enqueue q start;
  let is_valid (x, y) =
    let dimx = Array.length m in
    let dimy = Array.length m.(0) in
    let in_bounds = 0 <= x && x < dimx && 0 <= y && y < dimy in
    if in_bounds
    then (
      let c = m.(x).(y) in
      not (Char.equal '#' c))
    else false
  in
  let steps (x, y) =
    List.map directions ~f:(fun (xd, yd) -> x + xd, y + yd) |> List.filter ~f:is_valid
  in
  let equal (x1, y1) (x2, y2) = x1 = x2 && y1 = y2 in
  let rec loop i q =
    let q2 = Queue.create () in
    match i with
    | 64 -> q
    | _ ->
      let _ =
        Queue.fold q ~init:PosSet.empty ~f:(fun s p ->
          steps p
          |> List.fold ~init:s ~f:(fun s p ->
            match Set.exists s ~f:(equal p) with
            | true -> s
            | false ->
              Queue.enqueue q2 p;
              Set.add s p))
      in
      loop (i + 1) q2
  in
  let q = loop 0 q in
  let p1 = Queue.length q in
  Fmt.(pr "%d\n") p1;
  ()
;;
