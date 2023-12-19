open Core
open Advent.Symbols

module Workflow = struct
  module Rule = struct
    type t =
      | XGreater of int * string
      | XSmaller of int * string
      | MGreater of int * string
      | MSmaller of int * string
      | AGreater of int * string
      | ASmaller of int * string
      | SGreater of int * string
      | SSmaller of int * string
      | Next of string
      | Accept
      | Reject

    exception Invalid_rule of string

    let of_string str =
      let parse_next cs =
        String.of_list cs
        |> String.split ~on:':'
        |> fun p ->
        match p with
        | [ n; l ] -> Int.of_string n, l
        | _ -> raise (Invalid_rule "str")
      in
      match String.to_list str with
      | 'x' :: '>' :: num -> parse_next num |> fun (n, l) -> XGreater (n, l)
      | 'x' :: '<' :: num -> parse_next num |> fun (n, l) -> XSmaller (n, l)
      | 'm' :: '>' :: num -> parse_next num |> fun (n, l) -> MGreater (n, l)
      | 'm' :: '<' :: num -> parse_next num |> fun (n, l) -> MSmaller (n, l)
      | 'a' :: '>' :: num -> parse_next num |> fun (n, l) -> AGreater (n, l)
      | 'a' :: '<' :: num -> parse_next num |> fun (n, l) -> ASmaller (n, l)
      | 's' :: '>' :: num -> parse_next num |> fun (n, l) -> SGreater (n, l)
      | 's' :: '<' :: num -> parse_next num |> fun (n, l) -> SSmaller (n, l)
      | 'R' :: [] -> Reject
      | 'A' :: [] -> Accept
      | next -> Next (String.of_list next)
    ;;
  end

  module Input = struct
    type t =
      { x : int
      ; m : int
      ; a : int
      ; s : int
      }

    exception Invalid_input of string

    let of_string str =
      String.drop_prefix str 1
      |> fun str ->
      String.drop_suffix str 1
      |> String.split ~on:','
      |> List.fold ~init:{ x = 0; m = 0; a = 0; s = 0 } ~f:(fun ip str ->
        match String.to_list str with
        | 'x' :: '=' :: num -> { ip with x = String.of_list num |> Int.of_string }
        | 'm' :: '=' :: num -> { ip with m = String.of_list num |> Int.of_string }
        | 'a' :: '=' :: num -> { ip with a = String.of_list num |> Int.of_string }
        | 's' :: '=' :: num -> { ip with s = String.of_list num |> Int.of_string }
        | _ -> raise (Invalid_input str))
    ;;

    let x t = t.x
    let m t = t.m
    let a t = t.a
    let s t = t.s
    let sum t = t.x + t.m + t.a + t.s
  end

  type t =
    { label : string
    ; rules : Rule.t list
    }

  let of_string line =
    let cs = String.to_list line in
    let label = List.take_while cs ~f:(Char.equal '{' >> not) |> String.of_list in
    let rules =
      List.drop cs (String.length label + 1)
      |> List.take_while ~f:(Char.equal '}' >> not)
      |> String.of_list
      |> String.split ~on:','
      |> List.map ~f:Rule.of_string
    in
    { label; rules }
  ;;

  let label t = t.label
  let rules t = t.rules
end

module StrMap = Map.Make (String)

let cretae_wf_map workflows =
  let wf_map =
    List.fold workflows ~init:StrMap.empty ~f:(fun wf_m wf ->
      Map.add_exn wf_m ~key:(Workflow.label wf) ~data:wf)
  in
  let wf_map =
    Map.add_exn wf_map ~key:"A" ~data:{ label = "A"; rules = [ Workflow.Rule.Accept ] }
  in
  let wf_map =
    Map.add_exn wf_map ~key:"R" ~data:{ label = "R"; rules = [ Workflow.Rule.Reject ] }
  in
  wf_map
;;

let is_accepted wf_m input =
  let rules l = Map.find_exn wf_m l |> Workflow.rules in
  let open Workflow.Rule in
  let rec loop rs =
    match rs with
    | Accept :: [] -> true
    | Reject :: [] -> false
    | Next l :: [] -> loop (rules l)
    | XGreater (n, l) :: t ->
      if Workflow.Input.x input > n then loop (rules l) else loop t
    | XSmaller (n, l) :: t ->
      if Workflow.Input.x input < n then loop (rules l) else loop t
    | MGreater (n, l) :: t ->
      if Workflow.Input.m input > n then loop (rules l) else loop t
    | MSmaller (n, l) :: t ->
      if Workflow.Input.m input < n then loop (rules l) else loop t
    | AGreater (n, l) :: t ->
      if Workflow.Input.a input > n then loop (rules l) else loop t
    | ASmaller (n, l) :: t ->
      if Workflow.Input.a input < n then loop (rules l) else loop t
    | SGreater (n, l) :: t ->
      if Workflow.Input.s input > n then loop (rules l) else loop t
    | SSmaller (n, l) :: t ->
      if Workflow.Input.s input < n then loop (rules l) else loop t
    | _ -> failwith "oh no"
  in
  loop (Map.find_exn wf_m "in" |> Workflow.rules)
;;

let () =
  let lines = Advent.Input.read_lines "input/day19" in
  let workflows = List.take_while lines ~f:(fun line -> String.equal "" line |> not) in
  let inputs =
    List.drop lines (List.length workflows + 1) |> List.map ~f:Workflow.Input.of_string
  in
  let workflows = List.map workflows ~f:Workflow.of_string in
  let wf_map = cretae_wf_map workflows in
  let accepted = List.filter inputs ~f:(is_accepted wf_map) in
  let sum = List.fold accepted ~init:0 ~f:(fun sum inp -> sum + Workflow.Input.sum inp) in
  Fmt.(pr "%d\n") sum;
  ()
;;
