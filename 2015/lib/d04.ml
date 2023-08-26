open Base

let starts_with_zeroes (hex : string) zeroes : bool =
  let zr = Sequence.repeat '0' in
  let prefix = Sequence.take zr zeroes |> Sequence.to_list |> String.of_list in
  String.is_prefix ~prefix hex
;;

let md5_hash_string input : string =
  let open Digestif in
  let ctx = MD5.empty in
  let ctx = MD5.feed_string ctx input in
  let ctx = MD5.get ctx in
  MD5.to_hex ctx
;;

let rec find_hash_with_prefix secret num zeroes : int =
  let input = secret ^ Int.to_string num in
  let hash = md5_hash_string input in
  if starts_with_zeroes hash zeroes
  then num
  else find_hash_with_prefix secret (num + 1) zeroes
;;

let mine secret zeroes : int = find_hash_with_prefix secret 0 zeroes
