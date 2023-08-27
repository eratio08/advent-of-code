open Base

type 'a t =
  { w : int
  ; h : int
  ; arr : 'a array
  }

let init ~init w h =
  let arr =
    Sequence.repeat init |> (fun s -> Sequence.take s (w * h)) |> Sequence.to_array
  in
  { w; h; arr }
;;

let pos w x y = (y * w) + x

let get x y at =
  if y >= at.h
  then failwith (Int.to_string y ^ " >= " ^ Int.to_string at.h)
  else if x >= at.w
  then failwith (Int.to_string x ^ " >= " ^ Int.to_string at.w)
  else (
    let pos = pos at.w x y in
    at.arr.(pos))
;;

let set x y v at =
  let pos = pos at.w x y in
  at.arr.(pos) <- v;
  at
;;

let map ~f at =
  let w = at.w in
  let h = at.h in
  let arr = Array.map ~f at.arr in
  { w; h; arr }
;;

let fold ~init ~f at = Array.fold ~init ~f at.arr

let print (show : 'a -> string) at =
  for y = 0 to at.h - 1 do
    for x = 0 to at.w - 1 do
      let it = get x y at in
      let show = show it in
      Stdlib.print_string show;
      ()
    done;
    Stdio.print_endline ""
  done
;;

let count at = Array.length at.arr
