open Core
open Advent.Symbols

module TileType = struct
  type t =
    | MirrorLeft
    | MirrorRight
    | SplitterVert
    | SplitterHoriz
    | Empty

  let of_char = function
    | '/' -> MirrorLeft
    | '\\' -> MirrorRight
    | '|' -> SplitterVert
    | '-' -> SplitterHoriz
    | '.' -> Empty
    | _ -> failwith "uh no"
  ;;

  let to_string = function
    | MirrorLeft -> "/"
    | MirrorRight -> "\\"
    | SplitterVert -> "|"
    | SplitterHoriz -> "-"
    | Empty -> "."
  ;;

  let equal t1 t2 =
    match t1, t2 with
    | MirrorLeft, MirrorLeft
    | MirrorRight, MirrorRight
    | SplitterVert, SplitterVert
    | SplitterHoriz, SplitterHoriz
    | Empty, Empty -> true
    | _ -> false
  ;;
end

module Position = struct
  let to_string (x, y) = Int.to_string x ^ ";" ^ Int.to_string y
  let pp ppf (x, y) = Fmt.(pf ppf "@[<h>(%d,%d)@]@," x y)
  let pp_list ppf ts = Fmt.(pf ppf "@[<v>%a@]" (list ~sep:(any ";") pp) ts)

  let pp_set ppf ts =
    Fmt.(pf ppf "@[<h>[%a]@]" (list ~sep:(any ";@ ") string) (Set.to_list ts))
  ;;
end

module Direction = struct
  type t =
    | Up
    | Right
    | Down
    | Left

  let move (x, y) = function
    | Up -> x, y - 1
    | Right -> x + 1, y
    | Down -> x, y + 1
    | Left -> x - 1, y
  ;;

  let to_string = function
    | Up -> "Up"
    | Right -> "Right"
    | Down -> "Down"
    | Left -> "Left"
  ;;

  let next_direction tile t =
    match tile, t with
    | TileType.Empty, t -> [ t ]
    (* / *)
    | TileType.MirrorLeft, Up -> [ Right ]
    | TileType.MirrorLeft, Right -> [ Up ]
    | TileType.MirrorLeft, Down -> [ Left ]
    | TileType.MirrorLeft, Left -> [ Down ]
    (* \ *)
    | TileType.MirrorRight, Up -> [ Left ]
    | TileType.MirrorRight, Right -> [ Down ]
    | TileType.MirrorRight, Down -> [ Right ]
    | TileType.MirrorRight, Left -> [ Up ]
    (* | *)
    | TileType.SplitterVert, Right -> [ Up; Down ]
    | TileType.SplitterVert, Left -> [ Up; Down ]
    | TileType.SplitterVert, t -> [ t ]
    (* - *)
    | TileType.SplitterHoriz, Up -> [ Left; Right ]
    | TileType.SplitterHoriz, Down -> [ Left; Right ]
    | TileType.SplitterHoriz, t -> [ t ]
  ;;
end

let in_bounds m (x, y) =
  let dimx = Array.length m in
  let dimy = Array.length m.(0) in
  dimx > x && x >= 0 && dimy > y && y >= 0
;;

module StringSet = Set.Make (String)

let to_entry p d = Position.to_string p ^ Direction.to_string d

let walk ?(start = 0, 0) ?(d_start = Direction.Right) m =
  let rec loop res visited ((x, y) as p) d =
    match Set.exists visited ~f:(fun p_s -> to_entry p d |> String.equal p_s) with
    | true -> res, visited
    | false ->
      (match in_bounds m p with
       | false -> res, visited
       | true ->
         let res = Set.add res (Position.to_string p) in
         let tile = m.(x).(y) in
         let visited =
           if TileType.equal TileType.Empty tile |> not
           then Set.add visited (to_entry p d)
           else visited
         in
         let d = Direction.next_direction tile d in
         let p_d = List.map d ~f:(fun d -> Direction.move p d, d) in
         List.fold p_d ~init:(res, visited) ~f:(fun (res, visited) (p, d) ->
           loop res visited p d))
  in
  loop StringSet.empty StringSet.empty start d_start
;;

let gen_starts m =
  let dimx = Array.length m in
  let dimy = Array.length m.(0) in
  let t = List.range 0 dimx |> List.map ~f:(fun x -> (x, 0), Direction.Down) in
  let d = List.range 0 dimx |> List.map ~f:(fun x -> (x, dimy - 1), Direction.Up) in
  let l = List.range 0 dimy |> List.map ~f:(fun y -> (0, y), Direction.Right) in
  let r = List.range 0 dimy |> List.map ~f:(fun y -> (dimx - 1, y), Direction.Left) in
  List.concat [ t; r; d; l ]
;;

let () =
  let m =
    Advent.Input.read_lines "input/day16"
    |> List.map ~f:(String.to_list >> List.map ~f:TileType.of_char)
    |> Advent.Arraymatrix.to_m ~init:TileType.Empty
  in
  let path, _ = walk m in
  let cnt = Set.length path in
  Fmt.(pr "%d@ " cnt);
  (* *)
  let starts = gen_starts m in
  let cnt =
    List.map starts ~f:(fun (start, d_start) -> walk ~start ~d_start m)
    |> List.map ~f:(fun (path, _) -> Set.length path)
    |> List.max_elt ~compare:Int.compare
    |> Option.value ~default:0
  in
  Fmt.(pr "%d@ " cnt);
  ()
;;
