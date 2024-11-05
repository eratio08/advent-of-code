open Core

module LabeledVertex = struct
  include String

  let label t = t
end

module LabeledGraph = Advent.Graph.Graph (LabeledVertex)

let () =
  let lines : (LabeledVertex.t * LabeledVertex.t list) list =
    Advent.Input.read_lines "input/day25_test"
    |> List.map ~f:(fun line ->
      String.split line ~on:':'
      |> fun parts ->
      match parts with
      | [ v; adj ] -> v, Stdlib.String.trim adj |> String.split ~on:' '
      | _ -> failwith " ")
  in
  let g = LabeledGraph.empty in
  let g =
    List.fold lines ~init:g ~f:(fun g (v, adj) ->
      List.fold (v :: adj) ~init:g ~f:(fun g v -> LabeledGraph.add_vertex g v)
      |> fun g -> List.fold adj ~init:g ~f:(fun g u -> LabeledGraph.add_edge v u g))
  in
  Fmt.(pr "%a" LabeledGraph.pp g);
  ()
;;
