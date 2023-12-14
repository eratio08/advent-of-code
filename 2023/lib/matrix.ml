open Core

type 'a t =
  { data : 'a list
  ; i : int
  ; j : int
  }

let create i j ~f = { data = List.init (i * j) ~f; i; j }

let get t ~i ~j =
  let i = i + (j - (1 * t.j)) in
  List.nth t.data i
;;

let get_exn t ~i ~j = get t ~i ~j |> Option.value_exn

