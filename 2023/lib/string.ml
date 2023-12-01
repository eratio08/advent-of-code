open Core

let first s = Stdlib.String.get s 0 |> Char.to_string

let last s =
  let length = String.length s in
  Stdlib.String.get s (length - 1) |> Char.to_string
;;
