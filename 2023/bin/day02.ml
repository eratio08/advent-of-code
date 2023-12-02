open Core

module Cube = struct
  type t =
    | Red of int
    | Green of int
    | Blue of int

  exception Illegal_color of string

  (** Expects string like `number color` *)
  let of_string s =
    let s = Stdlib.String.trim s in
    let num, color = String.lsplit2_exn ~on:' ' s in
    match color with
    | "red" -> Red (Int.of_string num)
    | "green" -> Green (Int.of_string num)
    | "blue" -> Blue (Int.of_string num)
    | c -> raise (Illegal_color c)
  ;;
end

module Game = struct
  type t =
    { id : int
    ; red : int
    ; green : int
    ; blue : int
    }

  let empty_game id = { id; red = 0; green = 0; blue = 0 }
  let new_ id red green blue = { id; red; green; blue }

  let add_cube game cube : t =
    match cube with
    | Cube.Red n -> { game with red = Int.max game.red n }
    | Cube.Green n -> { game with green = Int.max game.green n }
    | Cube.Blue n -> { game with blue = Int.max game.blue n }
  ;;

  let id t = t.id

  (** Expects string like
      `Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red` *)
  let of_string line : t =
    let game_prefix = line |> String.take_while ~f:(fun c -> Char.equal ':' c |> not) in
    let id =
      game_prefix |> String.lsplit2_exn ~on:' ' |> Advent.Tuple.second |> Int.of_string
    in
    String.drop_prefix line (String.length game_prefix + 1)
    |> String.split ~on:';'
    |> List.bind ~f:(fun set -> String.split ~on:',' set |> List.map ~f:Cube.of_string)
    |> List.fold ~init:(empty_game id) ~f:add_cube
  ;;

  let contains game1 game2 =
    game1.red >= game2.red && game1.green >= game2.green && game1.blue >= game2.blue
  ;;
end

let () =
  let lines = Advent.Input.read_lines "input/day02" in
  let game = Game.new_ 0 12 13 14 in
  let games = lines |> List.map ~f:Game.of_string in
  let possible_game = games |> List.filter ~f:(Game.contains game) in
  let score =
    possible_game |> List.fold ~init:0 ~f:(fun score game -> score + Game.id game)
  in
  Fmt.pr "%d@\n" score;
  ()
;;
