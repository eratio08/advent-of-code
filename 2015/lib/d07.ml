open Base

(*
   123 -> x
   456 -> y
   x AND y -> d
   x OR y -> e
   x LSHIFT 2 -> f
   y RSHIFT 2 -> g
   NOT x -> h
   NOT y -> i
*)
type gate =
  | AND of char * char
  | OR of char * char
  | LSHIFT of char * int
  | RSHIFT of char * int
  | NOT of char
