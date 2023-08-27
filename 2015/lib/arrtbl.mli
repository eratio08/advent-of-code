open Base

(** Array backed table *)
type 'a t

(** Initialized an array table *)
val init : init:'a -> int -> int -> 'a t

(** Get a value from an array table *)
val get : int -> int -> 'a t -> 'a

(** Set va value to an array table *)
val set : int -> int -> 'a -> 'a t -> 'a t

(** Map over the internal array *)
val map : f:('a -> 'b) -> 'a t -> 'b t

(** Fold over the internal array *)
val fold : init:'b -> f:('b -> 'a -> 'b) -> 'a t -> 'b

(** Print table *)
val print : ('a -> string) -> 'a t -> unit

(** Count cells *)
val count : 'a t -> int
