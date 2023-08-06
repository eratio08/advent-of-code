open Base

type house = { x : int; y : int }

let show h : string = Printf.sprintf "House{x: %d, y: %d}" h.x h.y

let create_house (step : char) (pos : int * int) : house option =
  let x, y = pos in
  match step with
  | '^' -> Some { x; y = y + 1 }
  | '>' -> Some { x = x + 1; y }
  | 'v' -> Some { x; y = y - 1 }
  | '<' -> Some { x = x - 1; y }
  | _ -> None

let rec deliver_package (steps : char list) (pos : int * int)
    (houses : house list) : house list =
  match steps with
  | [] -> houses
  | step :: rest -> (
      match create_house step pos with
      | None -> deliver_package rest pos houses
      | Some house -> deliver_package rest (house.x, house.y) (house :: houses))

let deliver_packages (steps : string) : int =
  let steps = String.to_list steps in
  let houses = deliver_package steps (0, 0) [ { x = 0; y = 0 } ] in
  List.map houses ~f:show |> Set.of_list (module String) |> Set.length

let rec take_turns steps s_pos r_pos houses : house list =
  match steps with
  | [] -> houses
  | x :: [] -> (
      match create_house x s_pos with None -> houses | Some h -> h :: houses)
  | x :: y :: rest -> (
      let s_house = create_house x s_pos in
      let r_house = create_house y r_pos in
      match (s_house, r_house) with
      | None, None -> take_turns rest s_pos r_pos houses
      | Some x, None -> take_turns rest (x.x, x.y) r_pos (x :: houses)
      | None, Some x -> take_turns rest (x.x, x.y) r_pos (x :: houses)
      | Some x, Some y ->
          take_turns rest (x.x, x.y) (y.x, y.y) (x :: y :: houses))

let deliver_packages_with_robo steps =
  let steps = String.to_list steps in
  let houses = take_turns steps (0, 0) (0, 0) [ { x = 0; y = 0 } ] in
  List.map houses ~f:show |> Set.of_list (module String) |> Set.length
