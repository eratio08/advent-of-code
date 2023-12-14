let fst_exn = function
  | [] -> failwith "empty list"
  | h :: _ -> h
;;

let transpose m =
  let open Core in
  let dimx = List.hd_exn m |> List.length in
  let xs = List.init dimx ~f:(fun _ -> []) in
  List.fold m ~init:xs ~f:(fun xs row ->
    List.mapi xs ~f:(fun x l -> List.append l [ List.nth_exn row x ]))
;;
