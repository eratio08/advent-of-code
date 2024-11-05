open Core

module Position = struct
  type t = int * int [@@deriving compare, sexp]

  let equal (x1, y1) (x2, y2) = x1 = x2 && y1 = y2
end

module PosSet = Set.Make (Position)

let directions = [ 0, -1; 1, 0; 0, 1; -1, 0 ]

let start m =
  Array.find_mapi m ~f:(fun x cols ->
    Array.find_mapi cols ~f:(fun y c -> Option.some_if (Char.equal 'S' c) (x, y)))
  |> Option.value_exn
;;

let is_valid m (x, y) =
  let dimx = Array.length m in
  let dimy = Array.length m.(0) in
  let x = x % dimx in
  let y = y % dimy in
  let in_bounds = 0 <= x && x < dimx && 0 <= y && y < dimy in
  if in_bounds
  then (
    let c = m.(x).(y) in
    not (Char.equal '#' c))
  else false
;;

let steps m (x, y) =
  List.map directions ~f:(fun (xd, yd) -> x + xd, y + yd) |> List.filter ~f:(is_valid m)
;;

let move s m =
  let rec loop i q =
    let q2 = Queue.create () in
    match i with
    | n when n = s -> q
    | _ ->
      let _ =
        Queue.fold q ~init:PosSet.empty ~f:(fun s p ->
          steps m p
          |> List.fold ~init:s ~f:(fun s p ->
            match Set.exists s ~f:(Position.equal p) with
            | true -> s
            | false ->
              Queue.enqueue q2 p;
              Set.add s p))
      in
      loop (i + 1) q2
  in
  let start = start m in
  let q = Queue.create () in
  Queue.enqueue q start;
  loop 0 q
;;

let () =
  let m =
    Advent.Input.read_lines "input/day21" |> List.map ~f:String.to_array |> List.to_array
  in
  let q = move 64 m in
  let p1 = Queue.length q in
  Fmt.(pr "%d\n") p1;
  (* *)
  let q = move 26501365 m in
  let p2 = Queue.length q in
  Fmt.(pr "%d\n") p2;
  ()
;;
