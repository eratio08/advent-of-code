open Core

module Range = struct
  type t =
    { start : int
    ; end_ : int
    ; offset : int
    }

  let of_string line =
    let parts = String.split line ~on:' ' |> List.map ~f:Int.of_string in
    let dest = List.nth_exn parts 0 in
    let src = List.nth_exn parts 1 in
    let length = List.nth_exn parts 2 in
    let end_ = src + (length - 1) in
    let offset = dest - src in
    { start = src; end_; offset }
  ;;

  let contains t n = t.start <= n && n <= t.end_
  let to_destination t n = if contains t n then n + t.offset else n
end

module Map = struct
  type t =
    { name : string
    ; ranges : Range.t list
    }

  let of_strings lines =
    let name = List.nth_exn lines 0 |> fun str -> String.drop_suffix str 1 in
    let ranges = List.drop lines 1 |> List.map ~f:Range.of_string in
    { name; ranges }
  ;;

  let to_destination t n =
    List.find t.ranges ~f:(fun range -> Range.contains range n)
    |> Option.map ~f:(fun range -> Range.to_destination range n)
    |> Option.value ~default:n
  ;;
end

module Almanac = struct
  type t =
    { seeds : int list
    ; maps : Map.t list
    }

  let of_strings lines =
    let seeds =
      List.nth_exn lines 0
      |> fun str ->
      String.drop_prefix str 7 |> String.split ~on:' ' |> List.map ~f:Int.of_string
    in
    let rec loop res = function
      | [] -> res
      | lines ->
        let strs = List.take_while lines ~f:(fun l -> String.is_empty l |> not) in
        let map = Map.of_strings strs in
        let rest = List.drop lines (List.length strs + 1) in
        loop (List.append res [ map ]) rest
    in
    let lines = List.drop lines 2 in
    let maps = loop [] lines in
    { seeds; maps }
  ;;

  let seed_to_destination seed maps =
    maps |> List.fold ~init:seed ~f:(fun seed map -> Map.to_destination map seed)
  ;;

  let to_destination t =
    t.seeds |> List.map ~f:(fun seed -> seed_to_destination seed t.maps)
  ;;
end

let () =
  let lines = Advent.Input.read_lines "input/day05" in
  let almanac = Almanac.of_strings lines in
  let locations = Almanac.to_destination almanac in
  let min = List.min_elt ~compare:Int.compare locations |> Option.value_exn in
  Fmt.pr "Day 05\n";
  Fmt.pr "%d\n" min
;;
