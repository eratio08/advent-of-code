open Core
open Advent.Symbols

module ConditionRecord = struct
  let pp ppf (springs, checks) =
    Fmt.(
      pf
        ppf
        "@[<h>{ springs=%a;@ checks=[%a]@ }@]@;"
        (list char)
        springs
        (list ~sep:(any ";") int)
        checks)
  ;;

  let pp_list ppf ts = Fmt.(pf ppf "@[<v>[%a]@]" (list ~sep:(any "; ") pp) ts)

  let of_string line =
    let chars = String.to_list line in
    let springs = List.take_while chars ~f:(Char.equal ' ' >> not) in
    let checks =
      List.drop chars (List.length springs + 1)
      |> String.of_list
      |> String.split ~on:','
      |> List.map ~f:Int.of_string
    in
    springs, checks
  ;;

  let of_list lines = List.map lines ~f:of_string
  let cache = Hashtbl.create (module String)

  let rec count springs checks =
    match springs, checks with
    | _, [] -> if List.exists springs ~f:(Char.equal '#') then 0 else 1
    | [], _ -> 0
    | hs :: ts, hc :: tc ->
      Hashtbl.find_or_add cache (String.of_list springs) ~default:(fun () ->
        match hs with
        | '.' -> count ts checks
        | '#' -> count (List.drop ts hc) tc
        | '?' ->
          (match ts with
           | '.' :: _ -> 0
           | _ -> 0)
        | _ -> failwith "uh no")
  ;;
end

let () =
  let records = Advent.Input.read_lines "input/day12_test" |> ConditionRecord.of_list in
  Fmt.(pr "%a@;" ConditionRecord.pp_list records);
  let counts = List.map records ~f:(fun (s, c) -> ConditionRecord.count s c) in
  Fmt.(pr "[%a]@;" (list ~sep:(any ";") int) counts);
  ()
;;
