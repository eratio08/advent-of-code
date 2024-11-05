open Core

module DigPlan = struct
  module Direction = struct
    type t =
      | U
      | R
      | D
      | L

    let of_string = function
      | "U" -> U
      | "R" -> R
      | "D" -> D
      | "L" -> L
      | _ -> failwith "well..."
    ;;

    let to_string = function
      | U -> "U"
      | R -> "R"
      | D -> "D"
      | L -> "L"
    ;;

    let equal t1 t2 =
      match t1, t2 with
      | U, U | R, R | D, D | L, L -> true
      | _, _ -> false
    ;;

    let pp ppf t = Fmt.(pf ppf "%s" (to_string t))
  end

  module DigLine = struct
    type t =
      { direction : Direction.t
      ; length : int
      ; color : string
      }

    let direction t = t.direction

    let of_string s =
      match String.split s ~on:' ' with
      | [ direction; length; color ] ->
        let direction = Direction.of_string direction in
        let length = Int.of_string length in
        { direction; length; color }
      | _ -> failwith "mh..."
    ;;

    let pp ppf t =
      Fmt.(
        pf
          ppf
          "@[<h2>{ direction=%a; length=%d; color=%s }@]"
          Direction.pp
          t.direction
          t.length
          t.color)
    ;;

    let to_path t (x, y) =
      match t.direction with
      | U -> List.init t.length ~f:(fun i -> x, y - (i + 1))
      | R -> List.init t.length ~f:(fun i -> x + i + 1, y)
      | D -> List.init t.length ~f:(fun i -> x, y + (i + 1))
      | L -> List.init t.length ~f:(fun i -> x - (i + 1), y)
    ;;
  end

  let of_list lines = List.map lines ~f:DigLine.of_string

  let outlines m lines =
    let pos = ref (0, 0) in
    let _ =
      List.iter lines ~f:(fun line ->
        DigLine.to_path line !pos
        |> List.iter ~f:(fun (x, y) ->
          m.(x).(y) <- '#';
          pos := x, y))
    in
    m
  ;;

  let fill m =
    let dimx = Array.length m in
    let dimy = Array.length m.(0) in
    let inside = ref false in
    for y = 0 to dimy - 1 do
      for x = 0 to dimx - 1 do
        match m.(x).(y) with
        | '#' -> inside := not !inside
        | '.' -> if !inside then m.(x).(y) <- '#'
        | _ -> failwith ""
      done
    done;
    m
  ;;

  let count m =
    Array.fold m ~init:0 ~f:(fun cnt ys ->
      Array.fold ys ~init:cnt ~f:(fun cnt c ->
        match c with
        | '.' -> cnt
        | '#' -> cnt + 1
        | _ -> failwith "nono"))
  ;;
end

let print m =
  let dimx = Array.length m in
  let dimy = Array.length m.(0) in
  for y = 0 to dimy - 1 do
    for x = 0 to dimx - 1 do
      Fmt.(pr "%c") m.(x).(y)
    done;
    Fmt.(pr "\n")
  done;
  Fmt.(pr "\n")
;;

let () =
  let lines =
    Advent.Input.read_lines "input/day18_test" |> List.map ~f:DigPlan.DigLine.of_string
  in
  let m = Array.make_matrix ~dimx:15 ~dimy:10 '.' in
  print m;
  let m = DigPlan.outlines m lines in
  print m;
  let m = DigPlan.fill m in
  print m;
  let cnt = DigPlan.count m in
  Fmt.(pr "%d\n") cnt;
  ()
;;
