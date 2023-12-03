open Core

let first s = Stdlib.String.get s 0 |> Char.to_string

let last s =
  let length = String.length s in
  Stdlib.String.get s (length - 1) |> Char.to_string
;;

let drop_while s ~f =
  let rec loop = function
    | [] -> []
    | h :: t as l -> if f h then loop t else l
  in
  String.to_list s |> loop |> String.of_list
;;
