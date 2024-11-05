open Core
open Advent.Symbols

module TrailType = struct
  type t =
    | Path
    | Forest
    | UpSlope
    | RightSlope
    | DownSlope
    | LeftSlope
  [@@deriving equal]

  exception Invalid_path of char

  let of_char = function
    | '.' -> Path
    | '#' -> Forest
    | '^' -> UpSlope
    | '>' -> RightSlope
    | 'v' -> DownSlope
    | '<' -> LeftSlope
    | c -> raise (Invalid_path c)
  ;;

  (* let is_slope = function *)
  (*   | UpSlope | RightSlope | DownSlope | LeftSlope -> true *)
  (*   | _ -> false *)
  (* ;; *)
end

module Trail = struct
  let find_start m =
    Array.find_mapi m ~f:(fun x y ->
      Option.some_if (TrailType.equal TrailType.Path y.(0)) (x, 0))
  ;;

  let find_end m =
    let dimy = Array.length m.(0) - 1 in
    Array.find_mapi m ~f:(fun x y ->
      Option.some_if (TrailType.equal TrailType.Path y.(dimy)) (x, dimy))
  ;;

  let is_valid m (x, y) =
    let dimx = Array.length m in
    let dimy = Array.length m.(0) in
    let in_bounds = 0 <= x && x < dimx && 0 <= y && y < dimy in
    in_bounds && TrailType.equal TrailType.Forest m.(x).(y) |> not
  ;;

  (* let longest_ *)
end

let () =
  let trail =
    Advent.Input.read_lines "input/day23_test"
    |> List.map ~f:(String.to_list >> Array.of_list)
    |> Array.of_list
  in
  ()
;;
