let fst_exn = function
  | [] -> failwith "empty list"
  | h :: _ -> h
;;
