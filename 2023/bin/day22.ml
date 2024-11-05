open Core
open Advent.Symbols

module Interval = struct
  type t = int * int [@@deriving show]

  let contains (s, e) x = s <= x && x <= e

  let intersects ((s1, e1) as t1) ((s2, e2) as t2) =
    contains t1 s2 || contains t1 e2 || contains t2 s1 || contains t2 e1
  ;;
end

module Brick = struct
  (* ((xs,xe),(ys,ye),z) *)
  type t = Interval.t * Interval.t * Interval.t [@@deriving show]

  let of_string str =
    String.split str ~on:'~'
    |> List.map ~f:(String.split ~on:',' >> List.map ~f:Int.of_string)
    |> fun l ->
    match l with
    | [ [ xs; ys; zs ]; [ xe; ye; ze ] ] -> (xs, xe), (ys, ye), (zs, ze)
    | _ -> failwith "invalid brick"
  ;;

  (* let is_atop (x1,y1,z1) (x2,y2,z2) = *)
end

let () =
  let bricks =
    Advent.Input.read_lines "input/day22_test" |> List.map ~f:Brick.of_string
  in
  Fmt.(pr "Bricks: %a" (list Brick.pp) bricks);
  ()
;;
