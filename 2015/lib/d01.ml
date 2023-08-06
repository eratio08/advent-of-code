open Base

let move_floor (c : char) (floor : int) : int =
  match c with '(' -> floor + 1 | ')' -> floor - 1 | _ -> floor

let rec move' moves floor =
  match moves with [] -> floor | x :: rest -> move_floor x floor |> move' rest

let move (moves : string) : int =
  let moves = String.to_list moves in
  move' moves 0

let rec move_to_cellar (moves : char list) floor position : int =
  match floor with
  | -1 -> position
  | _ -> (
      match moves with
      | [] -> position
      | x :: rest ->
          let new_floor = move_floor x floor in
          let new_position = position + 1 in
          (* Stdio.printf "%d %d %c\n" new_floor new_position x; *)
          move_to_cellar rest new_floor new_position)

let detect_cellar move : int =
  let moves = String.to_list move in
  move_to_cellar moves 0 0
