open Core

let split_string_on_newlines s =
  let newline_regexp = Str.regexp "\n\n" in
  Str.split newline_regexp s
;;

module Segment = struct
  type t =
    { rows : string list
    ; columns : string list
    }

  let transpose rows =
    let dimx = List.hd_exn rows |> List.length in
    let xs = List.init dimx ~f:(fun _ -> []) in
    List.fold rows ~init:xs ~f:(fun xs row ->
      List.mapi xs ~f:(fun x l -> List.append l [ List.nth_exn row x ]))
  ;;

  let of_list rows =
    let rows_c = List.map rows ~f:String.to_list in
    let columns = transpose rows_c |> List.map ~f:String.of_list in
    { rows; columns }
  ;;

  let find_reflections t =
    let rec find_idx i res = function
      | [] -> res
      | h1 :: (h2 :: _ as t) when String.equal h1 h2 -> find_idx (i + 1) (i :: res) t
      | _ :: t -> find_idx (i + 1) res t
    in
    let is_full_reflection s n =
      let p1 = List.take s n |> List.rev in
      let p2 = List.drop s n |> fun s -> List.take s n in
      let p1, p2 =
        match List.length p1 - List.length p2 with
        | 0 -> p1, p2
        | diff when diff < 0 ->
          p1, List.rev p2 |> fun l -> List.drop l (Int.abs diff) |> List.rev
        | diff when diff > 0 ->
          List.rev p1 |> fun l -> List.drop l (Int.abs diff) |> List.rev, p2
        | _ -> failwith "wtf"
      in
      List.zip_exn p1 p2 |> List.for_all ~f:(fun (s1, s2) -> String.equal s1 s2)
    in
    let cnt s =
      let reflections = find_idx 1 [] s in
      List.filter reflections ~f:(is_full_reflection s)
      |> List.hd
      |> Option.value ~default:0
    in
    let h = cnt t.rows in
    let v = cnt t.columns in
    v + (h * 100)
  ;;
end

let () =
  let lines =
    Advent.Input.read_all "input/day13"
    |> split_string_on_newlines
    |> List.map ~f:String.split_lines
  in
  let segments = lines |> List.map ~f:Segment.of_list in
  let sum = List.map segments ~f:Segment.find_reflections |> List.fold ~init:0 ~f:( + ) in
  Fmt.pr "%d\n" sum;
  ()
;;
