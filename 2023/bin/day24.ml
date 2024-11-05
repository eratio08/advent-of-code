open Core

module HailStorm = struct
  type t =
    { location : int * int * int
    ; velocity : int * int * int
    }
  [@@deriving show]

  let of_string str =
    let parts = String.split ~on:'@' str in
    let parts =
      List.map parts ~f:(fun s ->
        String.split s ~on:','
        |> List.map ~f:Stdlib.String.trim
        |> List.map ~f:Int.of_string)
    in
    match parts with
    | [ [ x; y; z ]; [ xv; yv; zv ] ] -> { location = x, y, z; velocity = xv, yv, zv }
    | _ -> failwith ""
  ;;

  let at_n n { location = x, y, z; velocity = xv, yv, zv } : int * int * int =
    x + (n * xv), y + (n * yv), z + (n * zv)
  ;;
end

module Position = struct
  type t = int * int * int [@@deriving show]

  let intersect (x1, y1, _) (x2, y2, _) = ()
end

let () =
  let hailstorms =
    Advent.Input.read_lines "input/day24_test" |> List.map ~f:HailStorm.of_string
  in
  Fmt.(pr "%a\n" (list HailStorm.pp) hailstorms);
  let hailstorms = List.map hailstorms ~f:(HailStorm.at_n 10) in
  Fmt.(pr "%a\n" (list Position.pp) hailstorms);
  ()
;;
