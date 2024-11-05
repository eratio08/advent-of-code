open Core

module Gate = struct
  type t =
    | FlipFlop of bool
    | And
    | Broadcaster
    | Output

  let of_string t =
    match String.to_list t with
    | '%' :: t -> FlipFlop false, String.of_list t
    | '&' :: t -> And, String.of_list t
    | 'b' :: _ -> Broadcaster, "broadcaster"
    | _ -> failwith ""
  ;;

  (* let puls  p t =  *)
  (*   match p,t with *)
  (*   | true, FlipFlop false as t -> t *)
  (*   | false, FlipFlop s -> FlipFlop (not s) *)
  (*   |  *)
end

module StrMap = Map.Make (String)

module Config = struct
  type t =
    { label : string
    ; gate : Gate.t
    ; outs : string list
    }

  let of_string str =
    let parts = Str.split (Str.regexp " -> ") str in
    let gate, label = List.nth_exn parts 0 |> Gate.of_string in
    let outs = List.nth_exn parts 1 |> Str.split (Str.regexp ", ") in
    { label; gate; outs }
  ;;

  let label t = t.label
  let gate t = t.gate
  let outs t = t.outs
end

module Pulse = struct
  type t = bool * string
end

(* let push m = *)
(*   let steps = Queue.create () in *)
(*   let steps = Queue.enqueue (false, "broadcaster") in *)
(*   let rec loop steps = *)
(*     match Queue.dequeue steps with *)
(*     | None -> *)
(*       let b = Map.find_exn ~key:"broadcaster" in *)
(*       () *)
(*   in *)
(*   loop steps; *)
(*   () *)
(* ;; *)

let () =
  let lines = Advent.Input.read_lines "input/day20_test" in
  let m = StrMap.empty in
  let configs = List.map lines ~f:Config.of_string in
  let m =
    List.fold configs ~init:m ~f:(fun m config ->
      Map.add_exn m ~key:(Config.label config) ~data:config)
  in
  ()
;;

(*
   broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a

br -> %a -> b
   -> %b -> %c -> &inv -> %a
   -> %c -> &inv -> %a

  [br]a[b] [a]b[c]
  [br,b]c[inv]
  [c]inv[a}
*)
