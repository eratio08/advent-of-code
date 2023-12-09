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
end

module RingSeq = struct
  type 'a t =
    { seq : 'a list
    ; pos : int
    }

  let next t =
    let pos = if t.pos = List.length t.seq - 1 then 0 else t.pos + 1 in
    let n = List.nth_exn t.seq pos in
    n, { t with pos }
  ;;

  let of_string line =
    let seq = String.to_list line |> List.map ~f:Direction.of_string in
    { seq; pos = -1 }
  ;;
end

module StringMap = Map.Make (String)

module NetworkNode = struct
  let of_string line =
    let line = String.to_list line in
    let value = List.take line 3 |> String.of_list in
    let left = List.drop line 7 |> fun l -> List.take l 3 |> String.of_list in
    let right = List.drop line 12 |> fun l -> List.take l 3 |> String.of_list in
    value, (left, right)
  ;;

  let next (left, right) = function
    | Direction.L -> left
    | Direction.R -> right
  ;;
end

module Network = struct
  module StringMap = Map.Make (String)

  let of_list lines =
    let rec loop m = function
      | [] -> m
      | h :: t ->
        let key, nn = NetworkNode.of_string h in
        let m = Map.add_exn m ~key ~data:nn in
        loop m t
    in
    loop StringMap.empty lines
  ;;

  let step network seq key =
    let direction, seq = RingSeq.next seq in
    let node = Map.find_exn network key in
    let next = NetworkNode.next node direction in
    next, seq
  ;;

  let walk network seq start =
    let rec loop n seq key =
      let end_ = String.rev key |> fun s -> s.[0] in
      match end_ with
      | 'Z' -> n
      | _ ->
        let next, seq = step network seq key in
        loop (n + 1) seq next
    in
    loop 0 seq start
  ;;

  let find_starts t = Map.keys t |> List.filter ~f:(Stdlib.String.ends_with ~suffix:"A")

  let rec gcd a b =
    match a, b with
    | a, 0 -> a
    | a, b -> gcd b (a % b)
  ;;

  let lcm a b = a * b / gcd a b

  let walk' network seq =
    let starts = find_starts network in
    let steps = List.map starts ~f:(walk network seq) in
    List.fold steps ~init:1 ~f:(fun acc b -> lcm b acc)
  ;;
end

let () =
  let lines = Advent.Input.read_lines "input/day08" in
  let directions = List.nth_exn lines 0 |> RingSeq.of_string in
  let network = List.drop lines 1 |> Network.of_list in
  let steps = Network.walk network directions "AAA" in
  Fmt.pr "%d\n" steps;
  (* *)
  let steps = Network.walk' network directions in
  Fmt.pr "%d\n" steps
;;
