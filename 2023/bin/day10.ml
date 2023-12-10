open Core
open Advent.Symbols

module Direction = struct
  type t =
    | N
    | E
    | S
    | W

  let directions = [ N; E; S; W ]
end

module Position = struct
  type t =
    { x : int
    ; y : int
    }
  [@@deriving compare, sexp, hash]

  let create x y = { x; y }

  let next { x; y } = function
    | Direction.N -> { x; y = y - 1 }
    | Direction.E -> { x = x + 1; y }
    | Direction.S -> { x; y = y + 1 }
    | Direction.W -> { x = x - 1; y }
  ;;
end

module PositionMap = Map.Make (Position)

module TileKind = struct
  type t =
    | NorthSouth
    | EastWest
    | NorthEast
    | NorthWest
    | SouthWest
    | SouthEast
    | Ground
    | Start

  exception Illegal_tile of char

  let of_char = function
    | '|' -> NorthSouth
    | '-' -> EastWest
    | 'L' -> NorthEast
    | 'J' -> NorthWest
    | '7' -> SouthWest
    | 'F' -> SouthEast
    | '.' -> Ground
    | 'S' -> Start
    | c -> raise (Illegal_tile c)
  ;;

  let equal t1 t2 =
    match t1, t2 with
    | Start, Start
    | Ground, Ground
    | NorthSouth, NorthSouth
    | EastWest, EastWest
    | NorthEast, NorthEast
    | NorthWest, NorthWest
    | SouthWest, SouthWest
    | SouthEast, SouthEast -> true
    | _, _ -> false
  ;;

  let next kind direction =
    let open Direction in
    match kind, direction with
    | NorthSouth, S -> Some S
    | NorthSouth, N -> Some N
    | EastWest, E -> Some E
    | EastWest, W -> Some W
    | NorthEast, S -> Some E
    | NorthEast, W -> Some N
    | NorthWest, S -> Some W
    | NorthWest, E -> Some N
    | SouthWest, E -> Some S
    | SouthWest, N -> Some W
    | SouthEast, N -> Some E
    | SouthEast, W -> Some S
    | _, _ -> None
  ;;
end

module Tile = struct
  type t =
    { kind : TileKind.t
    ; position : Position.t
    }

  let ground position = { kind = TileKind.Ground; position }

  let create char x y =
    let kind = TileKind.of_char char in
    let position = Position.create x y in
    { kind; position }
  ;;

  let kind t = t.kind
  let position t = t.position

  let next t direction =
    TileKind.next t.kind direction
    |> Option.map ~f:(fun next_direction ->
      Position.next t.position direction, next_direction)
  ;;
end

module Landscape = struct
  type t =
    { start : Tile.t
    ; tiles : Tile.t PositionMap.t
    }

  let find_start tiles =
    Map.data tiles
    |> List.find_exn ~f:(fun tile -> Tile.kind tile |> TileKind.equal TileKind.Start)
  ;;

  let of_list lines =
    let lines = List.map lines ~f:String.to_list in
    let tiles =
      List.foldi lines ~init:PositionMap.empty ~f:(fun y m line ->
        List.foldi line ~init:m ~f:(fun x tiles tile ->
          Tile.create tile x y
          |> fun tile -> Map.add_exn tiles ~key:(Position.create x y) ~data:tile))
    in
    let start = find_start tiles in
    { start; tiles }
  ;;

  let walk t direction =
    let is_start tile = Tile.kind tile |> TileKind.equal TileKind.Start in
    let rec loop tiles tile direction =
      match direction with
      | None -> []
      | Some direction ->
        let tiles = tile :: tiles in
        let next_position = Position.next (Tile.position tile) direction in
        let next_tile =
          match Map.find t.tiles next_position with
          | None -> Tile.ground next_position
          | Some tile -> tile
        in
        if is_start next_tile
        then tiles
        else (
          let next_direction = TileKind.next (Tile.kind next_tile) direction in
          loop tiles next_tile next_direction)
    in
    loop [] t.start (Some direction)
  ;;

  let find_loop t =
    List.map Direction.directions ~f:(walk t) |> List.find_exn ~f:(List.is_empty >> not)
  ;;
end

let () =
  let lines = Advent.Input.read_lines "input/day10" in
  let landscape = Landscape.of_list lines in
  let loop = Landscape.find_loop landscape in
  let farest = List.length loop |> fun l -> l / 2 in
  Fmt.pr "%d\n" farest;
  ()
;;
