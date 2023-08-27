open Base

type point =
  { x : int
  ; y : int
  }

let show_point p = "(" ^ Int.to_string p.x ^ ", " ^ Int.to_string p.y ^ ")"

type action =
  | On
  | Off
  | Toggle

let show_action = function
  | On -> "on"
  | Off -> "off"
  | Toggle -> "toggle"
;;

type instruction =
  { action : action
  ; r_from : point
  ; r_to : point
  }

let show_instruction i =
  let a = show_action i.action in
  let p1 = show_point i.r_from in
  let p2 = show_point i.r_to in
  Printf.sprintf "{ action: %s; r_from: %s; r_to: %s }" a p1 p2
;;

let parse_point w =
  match String.split ~on:',' w with
  | [ x; y ] ->
    let x = Int.of_string x in
    let y = Int.of_string y in
    { x; y }
  | _ -> "invalid point " ^ w |> failwith
;;

let parse_action = function
  | "on" -> On
  | "off" -> Off
  | "toggle" -> Toggle
  | a -> "Unknown actions " ^ a |> failwith
;;

let parse_instruction line =
  let words = String.split ~on:' ' line in
  let a, p1, p2 =
    match words with
    | [ _; a; p1; _; p2 ] -> a, p1, p2
    | [ a; p1; _; p2 ] -> a, p1, p2
    | _ -> "Invalid line " ^ line |> failwith
  in
  let action = parse_action a in
  let r_from = parse_point p1 in
  let r_to = parse_point p2 in
  { action; r_from; r_to }
;;

let parse_instructions = List.map ~f:parse_instruction

let act b = function
  | On -> true
  | Off -> false
  | Toggle -> not b
;;

(* Apply instructions *)
let apply_instruction lights instruction =
  for y = instruction.r_from.y to instruction.r_to.y do
    for x = instruction.r_from.x to instruction.r_to.x do
      let light = Arrtbl.get x y lights in
      let light = act light instruction.action in
      let _ = Arrtbl.set x y light lights in
      ()
    done
  done;
  lights
;;

let apply_instructions lights instrcutions =
  List.fold
    ~init:lights
    ~f:(fun acc instrcution -> apply_instruction acc instrcution)
    instrcutions
;;

let show_bool = function
  | true -> "1"
  | false -> "0"
;;

let print_lights lights = lights |> Arrtbl.print show_bool

(* Count lights *)
let count_lights at =
  Arrtbl.fold ~init:0 ~f:(fun acc light -> if light then acc + 1 else acc) at
;;

let lit_lights lines =
  let instructions = parse_instructions lines in
  let lights = Arrtbl.init ~init:false 1000 1000 in
  let _ = apply_instructions lights instructions in
  count_lights lights
;;

let act' light = function
  | On -> light + 1
  | Off -> if light > 0 then light - 1 else light
  | Toggle -> light + 2
;;

let apply_instruction' lights instruction =
  for y = instruction.r_from.y to instruction.r_to.y do
    for x = instruction.r_from.x to instruction.r_to.x do
      let light = Arrtbl.get x y lights in
      let light = act' light instruction.action in
      let _ = Arrtbl.set x y light lights in
      ()
    done
  done;
  lights
;;

let apply_instructions' lights instrcutions =
  List.fold
    ~init:lights
    ~f:(fun acc instrcution -> apply_instruction' acc instrcution)
    instrcutions
;;

let count_lights' at = Arrtbl.fold ~init:0 ~f:(fun acc light -> acc + light) at

let lit_lights' lines =
  let instructions = parse_instructions lines in
  let lights = Arrtbl.init ~init:0 1000 1000 in
  let _ = apply_instructions' lights instructions in
  count_lights' lights
;;

