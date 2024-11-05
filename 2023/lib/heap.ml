(* open Core *)

module MaxHeap = struct
  type 'a t =
    | Empty
    | Node of 'a * 'a t * 'a t

  let empty = Empty

  let is_empty = function
    | Empty -> true
    | _ -> false
  ;;

  (*
     let merge t1 t2 = t1

     let merge heap1 heap2 = (* merge two Fibonacci heaps *)

     let insert element heap = (* insert an element into the heap *)

     let delete_min heap = (* remove and return the highest priority element *)

     let size heap = (* get the number of elements in the heap *)
  *)
end

(* module MinHeap : sig *)
(*   type 'a t *)
(**)
(*   (* val create : unit -> 'a t *) *)
(*   (* val is_empty : 'a t -> bool *) *)
(*   (* val insert : 'a t -> 'a -> unit *) *)
(*   (* val remove : 'a t -> 'a option *) *)
(* end = struct *)
(**)
(* end *)

module type Heap = sig
  type 'a t

  val top : 'a t -> 'a
  val peek : 'a t -> 'a t
  val insert : 'a t -> 'a -> int -> 'a t
  val remove : 'a t -> 'a -> 'a t
  val update : 'a t -> 'a -> int -> 'a t
end

module type PriorityQueue = sig
  include Heap

  val size : int
end

(*
   left: (2 * i) + 1
   right: 2 * (i + 1)
   parent: (i - 2) / 2
*)
(* module MaxHeap : Heap = struct *)
(*   type 'a t = 'a array *)
(**)
(*   let bubble_up *)
(* end *)
