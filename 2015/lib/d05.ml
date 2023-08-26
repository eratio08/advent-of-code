open Base

let vovels = Set.of_list (module Char) [ 'a'; 'e'; 'i'; 'o'; 'u' ]
let banned = Set.of_list (module String) [ "ab"; "cd"; "pq"; "xy" ]

let rec has_doubling = function
  | [] | [ _ ] -> false
  | (x : char) :: (y :: _ as rest) -> if phys_equal x y then true else has_doubling rest
;;

let rec not_contains_banned = function
  | [] | [ _ ] -> true
  | (x : char) :: (y :: _ as rest) ->
    if Set.mem banned (Char.to_string x ^ Char.to_string y)
    then false
    else not_contains_banned rest
;;

let rec contains_vovels ?(expected = 3) ?(count = 0) = function
  | [] -> expected <= count
  | x :: rest ->
    if Set.mem vovels x
    then contains_vovels ~expected ~count:(count + 1) rest
    else contains_vovels ~expected ~count rest
;;

let is_nice word =
  let cs = String.to_list word in
  let doubling = has_doubling cs in
  let no_banned = not_contains_banned cs in
  let vovels = contains_vovels cs in
  doubling && no_banned && vovels
;;

let count_nice ws = List.filter ~f:is_nice ws |> List.length

let is_pair (t : char * char * char) : bool =
  let a, _, c = t in
  let pair = phys_equal a c in
  pair
;;

let rec has_pairs = function
  | [] -> false
  | _ :: [] -> false
  | [ _; _ ] -> false
  | x :: (y :: z :: _ as rest) -> if is_pair (x, y, z) then true else has_pairs rest
;;

let windowed w cs =
  let rec windowed' res = function
    | [] -> res
    | r ->
      if List.length r < w
      then res
      else (
        let p = List.take r w in
        let r = List.drop r 1 in
        let res = List.append res [ p ] in
        windowed' res r)
  in
  windowed' [] cs
;;

let show_windowed =
  List.fold ~init:"" ~f:(fun acc p -> acc ^ "[" ^ String.of_list p ^ "]")
;;

let is_repeat (a, b) (x, y) : bool = phys_equal a x && phys_equal b y

let has_repeating cs =
  let rec has_repeating' p = function
    | [] -> false
    | x :: (y :: _ as rest) ->
      let res = is_repeat p (x, y) in
      if res then true else has_repeating' p rest
    | _ -> false
  in
  let rec repeats rest =
    match rest with
    | [] -> false
    | x :: (y :: search as rest) ->
      if has_repeating' (x, y) search then true else repeats rest
    | _ -> false
  in
  if List.length cs < 4 then false else repeats cs
;;

let is_nice' word =
  let cs = String.to_list word in
  let has_pairs = has_pairs cs in
  let has_repeating = has_repeating cs in
  let res = has_pairs && has_repeating in
  res
;;

let count_nice' ws = List.filter ws ~f:is_nice' |> List.length
