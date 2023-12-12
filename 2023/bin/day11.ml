open Core

module Coordinate = struct
  type t =
    { x : int
    ; y : int
    }

  let create x y = { x; y }
  let distance c1 c2 = Int.abs (c1.x - c2.x) + Int.abs (c1.y - c2.y)
  let pp ppf t = Fmt.pf ppf "{x=%d;y=%d}" t.x t.y
end

module Universe = struct
  let pp ppf m =
    let dimy = Array.length m.(0) in
    let dimx = Array.length m in
    Fmt.pf ppf "[%d,%d]\n" dimx dimy;
    for j = 0 to dimy - 1 do
      for i = 0 to dimx - 1 do
        Fmt.pf ppf "(%d,%d=%c)" i j m.(i).(j)
      done;
      Fmt.pf ppf "\n"
    done
  ;;

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

  let rotate_cw_90_ls ls =
    let m = to_m ls in
    let n = rotate_cw_90 m in
    of_m n
  ;;

  let rotate_ccw_90_ls ls =
    let m = to_m ls in
    let n = rotate_ccw_90 m in
    of_m n
  ;;

  let expand ls =
    let is_empty = List.for_all ~f:(fun c -> Char.equal '.' c) in
    let rec loop res = function
      | [] -> res
      | h :: t -> if is_empty h then loop (h :: h :: res) t else loop (h :: res) t
    in
    loop [] ls |> List.rev
  ;;

  let of_list lines =
    let ls = List.map lines ~f:String.to_list in
    let ls = expand ls in
    let m = to_m ls in
    let mr = rotate_cw_90 m in
    let rls = of_m mr in
    (* let ls_t = rotate_cw_90_ls ls in *)
    let ls_t = expand rls in
    rotate_ccw_90_ls ls_t
  ;;

  let find_galaxies ls =
    List.foldi ls ~init:[] ~f:(fun y acc row ->
      List.foldi row ~init:acc ~f:(fun x acc c ->
        match c with
        | '#' -> Coordinate.create x y :: acc
        | _ -> acc))
    |> List.rev
  ;;

  let distances gs =
    Fmt.pr "%a\n" (Fmt.list Coordinate.pp) gs;
    let pairs =
      List.foldi gs ~init:[] ~f:(fun i ps g ->
        let others = List.drop gs (i + 1) in
        let g_list =
          Seq.repeat g |> Seq.take (List.length others) |> Stdlib.List.of_seq
        in
        List.zip_exn g_list others |> List.append ps)
    in
    Fmt.pr "%d\n" (List.length pairs);
    List.map pairs ~f:(fun (g1, g2) ->
      Coordinate.distance g1 g2
      |> fun (d : int) ->
      Fmt.pr "%a %a -> %d\n" Coordinate.pp g1 Coordinate.pp g2 d;
      d)
  ;;
end

let () =
  let lines = Advent.Input.read_lines "input/day11" in
  let universe = Universe.of_list lines in
  let galaxies = Universe.find_galaxies universe in
  let distances = Universe.distances galaxies in
  let sum = List.fold distances ~init:0 ~f:( + ) in
  Fmt.pr "%d\n" sum;
  ()
;;
