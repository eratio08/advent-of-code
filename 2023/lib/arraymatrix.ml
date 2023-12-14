open Core

let rotate_ccw_90 m =
  let dimy = Array.length m.(0) in
  let dimx = Array.length m in
  let t = Array.make_matrix ~dimx:dimy ~dimy:dimx '.' in
  for j = 0 to dimy - 1 do
    for i = 0 to dimx - 1 do
      t.(j).(dimx - 1 - i) <- m.(i).(j)
    done
  done;
  t
;;

let rotate_cw_90 m =
  let dimy = Array.length m.(0) in
  let dimx = Array.length m in
  let t = Array.make_matrix ~dimx:dimy ~dimy:dimx '.' in
  for j = 0 to dimy - 1 do
    for i = 0 to dimx - 1 do
      t.(dimy - 1 - j).(i) <- m.(i).(j)
    done
  done;
  t
;;

let to_m ls =
  let dimx = List.hd_exn ls |> List.length in
  let dimy = List.length ls in
  let m = Array.make_matrix ~dimx ~dimy '.' in
  List.foldi ls ~init:m ~f:(fun j m l ->
    List.foldi l ~init:m ~f:(fun i m p ->
      m.(i).(j) <- p;
      m))
;;

let of_m m =
  let dimy = Array.length m.(0) in
  let ly = List.init dimy ~f:(fun _ -> []) in
  Array.fold m ~init:ly ~f:(fun ly xys -> List.mapi ly ~f:(fun y l -> xys.(y) :: l))
;;
