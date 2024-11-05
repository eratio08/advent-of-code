module type Comparable = sig
  type t

  val compare : t -> t -> int
end

module BinTree (M : Comparable) : sig
  type 'a t

  val singleton : M.t -> M.t t
  val insert : M.t -> M.t t -> M.t t
  val delete : M.t -> M.t t -> M.t t
  val contains : M.t -> M.t t -> bool
  val height : M.t t -> int
end = struct
  type 'a t =
    | Empty
    | Node of M.t * M.t t * M.t t

  let singleton x = Node (x, Empty, Empty)

  let rec insert x = function
    | Empty -> singleton x
    | Node (a, _, _) as t when M.compare x a = 0 -> t
    | Node (a, left, right) when M.compare x a < 0 -> Node (a, insert x left, right)
    | Node (a, left, right) when M.compare x a > 0 -> Node (a, left, insert x right)
    | Node _ -> failwith "please the type system"
  ;;

  let rec find_min_exn = function
    | Empty -> failwith "no min element"
    | Node (a, Empty, _) -> a
    | Node (_, left, _) -> find_min_exn left
  ;;

  let rec remove_min = function
    | Empty -> failwith "no min element to remove"
    | Node (_, Empty, right) -> right
    | Node (a, left, right) -> Node (a, remove_min left, right)
  ;;

  let rec delete x t =
    match t with
    | Empty -> Empty
    | Node (a, left, right) when M.compare x a < 0 -> Node (a, delete x left, right)
    | Node (a, left, right) when M.compare x a > 0 -> Node (a, left, delete x right)
    | Node (a, _, _) as t when M.compare x a = 0 ->
      (match t with
       | Node (_, Empty, Empty) -> Empty
       | Node (_, left, Empty) -> left
       | Node (_, Empty, right) -> right
       | Node (_, left, right) ->
         let min = find_min_exn right in
         Node (min, left, remove_min right)
       | _ -> failwith "Invalid case")
    | Node _ -> failwith "Invalid case"
  ;;

  let rec contains x = function
    | Empty -> false
    | Node (a, _, _) when M.compare x a = 0 -> true
    | Node (a, left, _) when M.compare x a < 0 -> contains x left
    | Node (a, _, right) when M.compare x a > 0 -> contains x right
    | Node _ -> failwith "please the type system"
  ;;

  let rec height = function
    | Empty -> 0
    | Node (_, left, right) -> 1 + Int.max (height left) (height right)
  ;;

  (*
     4
     2    8
     1  3  6  9
     7
     1
     2
     3
     4

     4
     3
     2
     1
  *)

  (* let rec balance = function *)
  (*   | Empty -> Empty *)
  (*   | Node (_, Empty, Empty) -> Empty *)
  (*   | Node (n, left, right) -> *)
  (*     let hl = height left in *)
  (*     let hr = height right in *)
  (*     Empty *)
  (* ;; *)
end
