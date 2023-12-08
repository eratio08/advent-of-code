open Core

module Direction = struct
  type t =
    | L
    | R

  exception Invalid_direction of char

  let of_string = function
    | 'L' -> L
    | 'R' -> R
    | c -> raise (Invalid_direction c)
  ;;

  let to_string = function
    | L -> "L"
    | R -> "R"
  ;;
end

module RingSeq = struct
  type 'a t =
    { seq : 'a list
    ; pos : int
    }

  let next t =
    let pos = if t.pos = List.length t.seq - 1 then 0 else t.pos + 1 in
    let n = List.nth_exn t.seq pos in
    { t with pos }, n
  ;;

  let of_string line =
    let seq = String.to_list line |> List.map ~f:Direction.of_string in
    { seq; pos = -1 }
  ;;
end

module StringMap = Map.Make (String)

module NetworkNode = struct
  type t = string * string * string

  let of_string line =
    let line = String.to_list line in
    let value = List.take line 3 |> String.of_list in
    let left = List.drop line 7 |> fun l -> List.take l 3 |> String.of_list in
    let right = List.drop line 12 |> fun l -> List.take l 3 |> String.of_list in
    left, value, right
  ;;

  let next (left, _, right) = function
    | Direction.L -> left
    | Direction.R -> right
  ;;
end

module Network = struct
  module StringMap = Map.Make (String)

  type t = StringMap

  let of_list lines =
    let rec loop m = function
      | [] -> m
      | h :: t ->
        let ((_, value, _) as nn) = NetworkNode.of_string h in
        let m = Map.add_exn m ~key:value ~data:nn in
        loop m t
    in
    loop StringMap.empty lines
  ;;

  let walk network s =
    let rec loop n s cur =
      match cur with
      | _, "ZZZ", _ -> n
      | cur ->
        let s, d = RingSeq.next s in
        let next = NetworkNode.next cur d in
        let cur = Map.find_exn network next in
        loop (n + 1) s cur
    in
    let start = Map.find_exn network "AAA" in
    loop 0 s start
  ;;
end

let () =
  let lines = Advent.Input.read_lines "input/day08" in
  let directions = List.nth_exn lines 0 |> RingSeq.of_string in
  let network = List.drop lines 1 |> Network.of_list in
  let steps = Network.walk network directions in
  Fmt.pr "%d\n" steps;
  ()
;;
