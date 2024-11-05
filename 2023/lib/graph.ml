open Core

module type Vertex = sig
  type t

  val label : t -> string
  val compare : t -> t -> int
  val equal : t -> t -> bool
  val t_of_sexp : Sexp.t -> t
  val sexp_of_t : t -> Sexp.t
  val hash : t -> int
  val create : t
  val pp : Format.formatter -> t -> unit
end

module Graph (V : Vertex) = struct
  module Edge = struct
    type t =
      { source : V.t
      ; dest : V.t
      ; weight : int
      ; label : string
      }
    [@@deriving show]

    let dest t = t.dest
    let create ~source ~dest ~weight ~label = { source; dest; weight; label }
  end

  module VertexMap = Map.Make (V)

  type t =
    { vertices : V.t list
    ; adjacency_list : Edge.t list VertexMap.t
    }

  let empty = { vertices = []; adjacency_list = VertexMap.empty }
  let add_vertex t v = { t with vertices = v :: t.vertices }
  let exists t v = List.exists t.vertices ~f:(V.equal v)

  let are_adjacent t v u =
    match
      List.exists t.vertices ~f:(V.equal v) && List.exists t.vertices ~f:(V.equal u)
    with
    | true ->
      Map.find t.adjacency_list v
      |> Option.value ~default:[]
      |> List.exists ~f:(fun e -> V.equal (Edge.dest e) u)
    | false -> failwith "Vertex not in graph"
  ;;

  let remove_edge t v u =
    match
      List.exists t.vertices ~f:(V.equal v) && List.exists t.vertices ~f:(V.equal u)
    with
    | true ->
      Map.update t.adjacency_list v ~f:(fun l ->
        Option.value l ~default:[]
        |> List.filter ~f:(fun e -> Edge.dest e |> V.compare u |> Stdlib.( != ) 0))
      |> fun adjacency_list -> { t with adjacency_list }
    | false -> failwith "edge does not exist"
  ;;

  let add_edge v u ?(weight = 0) ?(label = "") t =
    match are_adjacent t v u with
    | true ->
      remove_edge t v u
      |> fun t ->
      Map.update t.adjacency_list v ~f:(fun l ->
        Option.value l ~default:[]
        |> fun l -> Edge.create ~source:v ~dest:u ~weight ~label :: l)
      |> fun adjacency_list -> { t with adjacency_list }
    | false -> t
  ;;

  let bfs t s is_goal =
    let q = Queue.create () in
    Queue.enqueue q s;
    let distance = Hashtbl.create (module V) in
    let parents = Hashtbl.create (module V) in
    List.iter t.vertices ~f:(fun v -> Hashtbl.set distance ~key:v ~data:Int.max_value);
    Hashtbl.set distance ~key:s ~data:0;
    let res = ref None in
    while not (Queue.is_empty q) do
      let v = Queue.dequeue_exn q in
      match is_goal v with
      | true -> res := Some (v, parents)
      | false ->
        Map.find t.adjacency_list v
        |> Option.value ~default:[]
        |> List.iter ~f:(fun e ->
          let u = Edge.dest e in
          match Hashtbl.find_exn distance u with
          | n when n = Int.max_value ->
            Hashtbl.set distance ~key:u ~data:(Hashtbl.find_exn distance v + 1);
            Hashtbl.set parents ~key:u ~data:v;
            Queue.enqueue q u
          | _ -> ())
    done;
    res
  ;;

  (* let dijkstra t s is_goal = *)
  (*   let q = Queue.create () in *)
  (*   Queue.enqueue q s; *)
  (*   let distance = Hashtbl.create (module V) in *)
  (*   let parents = Hashtbl.create (module V) in *)
  (*   Hashtbl.set t ~key:s ~data:0; *)
  (*   while not (Queue.is_empty q) do *)
  (*     let v = Queue.min_elt q ~compare:V.compare in *)
  (*     () *)
  (*   done *)
  (* ;; *)
end
