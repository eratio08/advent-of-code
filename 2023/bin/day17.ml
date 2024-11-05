open Core

module Coordinate = struct
  type t = int * int [@@deriving sexp, hash, compare]

  let create x y = x, y
  let add (x1, y1) (x2, y2) = x1 + x2, y1 + y2
end

module Node = struct
  type 'a t =
    { value : 'a
    ; pos : Coordinate.t
    }
  [@@deriving sexp, hash, compare]
end

module CoordinateMap = Map.Make (Coordinate)

let in_bounds m (x, y) =
  let dimx = Array.length m in
  let dimy = Array.length m.(0) in
  0 <= x && x < dimx && 0 <= y && y < dimy
;;

let directions = [ 0, -1; 1, 0; 0, 1; -1, 0 ]

let adj_notes m coord =
  List.map directions ~f:(Coordinate.add coord) |> List.filter ~f:(in_bounds m)
;;

let shortest_path m ~start:(xs, ys) ~target:(xt, yt) =
  let dimx = Advent.Arraymatrix.dimx m in
  let dimy = Advent.Arraymatrix.dimy m in
  let distance = Array.make_matrix ~dimx ~dimy Int.max_value in
  let visited = Array.make_matrix ~dimx ~dimy false in
  distance.(xs).(ys) <- m.(xs).(ys);
  visited.(xs).(ys) <- true;
  let rec loop ((xc, yc) as cur) res = function
    | [] -> res
    | h :: t -> res
  in
  ()
;;

let determine_target m =
  let dimx = Array.length m in
  let dimy = Array.length m.(0) in
  dimx - 1, dimy - 1
;;

let () =
  let m =
    Advent.Input.read_lines "input/day17_test"
    |> List.map ~f:(fun l ->
      String.to_list l |> List.map ~f:String.of_char |> List.map ~f:Int.of_string)
    |> Advent.Arraymatrix.to_m ~init:(-1)
  in
  let target = determine_target m in
  ()
;;
