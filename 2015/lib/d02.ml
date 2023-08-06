open Base

type parcel = Rectangle of int * int * int

let from_line l : parcel option =
  match String.split l ~on:'x' with
  | [ l; w; h ] ->
      Some (Rectangle (Int.of_string l, Int.of_string w, Int.of_string h))
  | _ -> None

let from_lines ls : parcel list =
  List.map ls ~f:from_line
  |> List.concat_map ~f:(fun o -> match o with None -> [] | Some x -> [ x ])

let sides (p : parcel) : int * int * int =
  match p with
  | Rectangle (l, w, h) ->
      let a = 2 * l * w in
      let b = 2 * w * h in
      let c = 2 * h * l in
      (a, b, c)

let surface (p : parcel) : int = match sides p with a, b, c -> a + b + c

let smallest_side (p : parcel) : int =
  let (Rectangle (l, w, h)) = p in
  let sorted = List.sort [ l * w; w * h; h * l ] ~compare:(fun a b -> a - b) in
  match List.nth sorted 0 with None -> 0 | Some x -> x

let paper (p : parcel) : int =
  let a = surface p in
  let s = smallest_side p in
  a + s

let determine_paper ls : int =
  let recs = from_lines ls in
  List.fold recs ~init:0 ~f:(fun acc r -> paper r + acc)

let ribbon (p : parcel) : int =
  let (Rectangle (l, w, h)) = p in
  let sorted = List.sort [ l; w; h ] ~compare:(fun a b -> a - b) in
  match sorted with a :: b :: _ -> a + a + b + b | _ -> 0

let bow_ribbon (p : parcel) : int =
  let (Rectangle (l, w, h)) = p in
  l * w * h

let determine_ribbon ls : int =
  let recs = from_lines ls in
  List.fold recs ~init:0 ~f:(fun acc r -> ribbon r + bow_ribbon r + acc)
