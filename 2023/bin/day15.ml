open Core

let hash s =
  String.strip ~drop:Char.is_whitespace s
  |> String.fold ~init:0 ~f:(fun acc c ->
    Char.to_int c |> ( + ) acc |> ( * ) 17 |> fun n -> Int.rem n 256)
;;

module Lense = struct
  type t =
    { hash : int
    ; label : string
    ; focal_length : int
    }

  let of_string str =
    let label =
      String.to_list str
      |> List.take_while ~f:(fun c -> (Char.equal '-' c || Char.equal '=' c) |> not)
      |> String.of_list
      |> String.strip ~drop:Char.is_whitespace
    in
    let focal_length =
      String.substr_index str ~pattern:"="
      |> Option.map ~f:(fun idx ->
        String.drop_prefix str (idx + 1)
        |> String.strip ~drop:Char.is_whitespace
        |> Int.of_string)
      |> Option.value ~default:0
    in
    let hash = hash label in
    { hash; label; focal_length }
  ;;

  let equal t1 t2 = String.equal t1.label t2.label
  let hash t = t.hash

  let score_box =
    List.foldi ~init:0 ~f:(fun i sum lense ->
      ((lense.hash + 1) * (i + 1) * lense.focal_length) + sum)
  ;;

  let pp ppf t =
    Fmt.(
      pf ppf "@[<h>{ hash=%d; label=%s; focal_length=%d }@]" t.hash t.label t.focal_length)
  ;;

  let pp_box ppf t = Fmt.(pf ppf "@[<v>[ %a ]@]" (vbox (list ~sep:(any ";@;") pp)) t)
end

module IntMap = Map.Make (Int)

module Op = struct
  type t =
    | Add of Lense.t
    | Remove of Lense.t

  let of_string str =
    let lense = Lense.of_string str in
    if String.is_suffix str ~suffix:"-" then Remove lense else Add lense
  ;;

  let pp ppf t =
    match t with
    | Add _ -> Fmt.(pf ppf "Add")
    | Remove _ -> Fmt.(pf ppf "Remove")
  ;;

  let process m op =
    let replace_first lenses lense =
      let rec loop res = function
        | [] -> lense :: res
        | h :: t ->
          if Lense.equal lense h
          then lense :: res |> List.append (List.rev t)
          else loop (h :: res) t
      in
      loop [] lenses |> List.rev
    in
    let add m lense =
      Map.update m (Lense.hash lense) ~f:(fun lenses ->
        match lenses with
        | None -> [ lense ]
        | Some lenses -> replace_first lenses lense)
    in
    let remove_first lenses lense =
      let rec loop res = function
        | [] -> res
        | h :: t ->
          if Lense.equal lense h then List.append (List.rev t) res else loop (h :: res) t
      in
      loop [] lenses |> List.rev
    in
    let remove m lense =
      Map.update m (Lense.hash lense) ~f:(fun lenses ->
        match lenses with
        | None -> []
        | Some lenses -> remove_first lenses lense)
    in
    match op with
    | Add lense -> add m lense
    | Remove lense -> remove m lense
  ;;
end

let print boxes =
  Map.iteri boxes ~f:(fun ~key ~data -> Fmt.(pr "@[<2>[%d] %a@]@." key Lense.pp_box data))
;;

let () =
  Fmt.pr "HASH=%d\n" (hash "HASH");
  let lines = Advent.Input.read_all "input/day15" in
  let instructions = String.split lines ~on:',' in
  let n = List.fold instructions ~init:0 ~f:(fun acc s -> hash s + acc) in
  Fmt.pr "%d\n" n;
  (* *)
  let operations = List.map instructions ~f:Op.of_string in
  let boxes = List.fold operations ~init:IntMap.empty ~f:Op.process in
  print boxes;
  let focusing_power =
    Map.data boxes |> List.fold ~init:0 ~f:(fun acc box -> Lense.score_box box + acc)
  in
  Fmt.pr "%d\n" focusing_power;
  ()
;;
