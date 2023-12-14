open Core

let move_stones stones =
  let rec loop res spaces = function
    | [] -> List.append spaces res
    | h :: t when Char.equal 'O' h -> loop (h :: res) spaces t
    | h :: t when Char.equal '.' h -> loop res (h :: spaces) t
    | h :: t when Char.equal '#' h -> loop (h :: List.append spaces res) [] t
    | _ -> failwith "something is off"
  in
  loop [] [] stones |> List.rev
;;

let pp = Fmt.pr "%a\n" (Fmt.hbox (Fmt.list ~sep:(Fmt.any "\n") (Fmt.list Fmt.char)))

let determine_load stones =
  List.rev stones
  |> List.foldi ~init:0 ~f:(fun i acc stones ->
    let stones = List.filter stones ~f:(Char.equal 'O') in
    ((i + 1) * List.length stones) + acc)
;;

let () =
  let m = Advent.Input.read_lines "input/day14" |> List.map ~f:String.to_list in
  let m = Advent.List.transpose m in
  let m = List.map ~f:move_stones m in
  let m = Advent.List.transpose m in
  let load = determine_load m in
  Fmt.pr "%d\n" load;
  ()
;;
