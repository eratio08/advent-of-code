open Core

(* open interval *)
type range =
  { start : int
  ; len : int
  }

module RangeMapping = struct
  type t =
    { from : int
    ; to_ : int
    ; size : int
    }

  let of_string line =
    let parts = String.split line ~on:' ' |> List.map ~f:Int.of_string in
    let to_ = List.nth_exn parts 0 in
    let from = List.nth_exn parts 1 in
    let size = List.nth_exn parts 2 in
    { from; to_; size }
  ;;

  let end_ t = t.from + t.size
  let start t = t.start
  let contains t n = t.from <= n && n < end_ t
  let to_destination t n = n + t.size

  let intersections rm r =
    let e = r.start + r.len in
    let e' = rm.from + rm.size in
    let mk start en = { start; len = en - start } in
    if r.start > e'
    then [ r ]
    else if e < rm.from
    then [ r ]
    else if r.start < rm.from
    then
      mk r.start (rm.from - 1)
      :: (if e <= e' then [ mk rm.from e ] else [ mk rm.from e'; mk (e' + 1) e ])
    else if r.start <= e'
    then if e <= e' then [ mk r.start e ] else [ mk r.start e'; mk (e' + 1) e ]
    else []
  ;;
end

module Mapping = struct
  type t = { r_mappings : RangeMapping.t list }

  let of_strings lines =
    let r_mappings = List.drop lines 1 |> List.map ~f:RangeMapping.of_string in
    { r_mappings }
  ;;

  let to_destination t n =
    List.find t.r_mappings ~f:(fun rm -> RangeMapping.contains rm n)
    |> Option.map ~f:(fun rm -> RangeMapping.to_destination rm n)
    |> Option.value ~default:n
  ;;

  (* let to_destination' t r = *)
  (*   let res = *)
  (*     List.filter t.ranges ~f:(fun range -> Range.contains' range r) *)
  (*     |> List.map ~f:(fun range -> Range.to_destination' range r) *)
  (*     |> fun ranges -> if List.is_empty ranges then [ r ] else ranges *)
  (*   in *)
  (*   List.iter res ~f:(fun (s, e) -> Fmt.pr "-> (%d,%d)\n" s e); *)
  (*   res *)
  (* ;; *)
end

module Almanac = struct
  type t =
    { seeds : int list
    ; maps : Mapping.t list
    ; seed_ranges : (int * int) list
    }

  let of_strings lines =
    let seeds =
      List.nth_exn lines 0
      |> fun str ->
      String.drop_prefix str 7 |> String.split ~on:' ' |> List.map ~f:Int.of_string
    in
    let rec loop res = function
      | [] -> res
      | lines ->
        let strs = List.take_while lines ~f:(fun l -> String.is_empty l |> not) in
        let map = Mapping.of_strings strs in
        let rest = List.drop lines (List.length strs + 1) in
        loop (List.append res [ map ]) rest
    in
    let lines = List.drop lines 2 in
    let maps = loop [] lines in
    { seeds; maps; seed_ranges = [] }
  ;;

  let seed_to_destination seed maps =
    let rec loop seed = function
      | [] -> seed
      | mapping :: t -> loop (Mapping.to_destination mapping seed) t
    in
    loop seed maps
  ;;

  let to_destination t =
    let rec loop res = function
      | [] -> res
      | seed :: tail ->
        let destination = seed_to_destination seed t.maps in
        loop (destination :: res) tail
    in
    loop [] t.seeds |> List.rev
  ;;

  (* let seed_to_destination' r maps = *)
  (*   Fmt.pr "\n\n#seed_to_destinatioa\n"; *)
  (*   let rec loop destinations = function *)
  (*     | [] -> destinations *)
  (*     | mapping :: t -> *)
  (*       let destinations = List.bind destinations ~f:(Mapping.to_destination' mapping) in *)
  (*       Fmt.pr "\n"; *)
  (*       loop destinations t *)
  (*   in *)
  (*   let res = loop [ r ] maps in *)
  (*   List.iter ~f:(fun (s, e) -> Fmt.pr "(%d,%d)" s e) res; *)
  (*   Fmt.pr "\n\n"; *)
  (*   res *)
  (* ;; *)

  (* let to_destination' t = *)
  (*   Fmt.pr "#to_destination'\n"; *)
  (*   let rec loop res = function *)
  (*     | [] -> res *)
  (*     | r :: tail -> *)
  (*       let destinations = seed_to_destination' r t.maps in *)
  (*       loop (List.append res destinations) tail *)
  (*   in *)
  (*   loop [] t.seed_ranges *)
  (* ;; *)

  let seeds_to_ranges t =
    let rec loop res = function
      | [] -> res
      | h1 :: h2 :: t ->
        let range = h1, h1 + h2 - 1 in
        loop (range :: res) t
      | _ -> failwith "this seeds are uneven"
    in
    let seed_ranges = loop [] t.seeds |> List.rev in
    { t with seed_ranges }
  ;;
end

let () =
  let lines = Advent.Input.read_lines "input/day05_test" in
  let almanac = Almanac.of_strings lines in
  let locations = Almanac.to_destination almanac in
  let min = List.min_elt ~compare:Int.compare locations |> Option.value_exn in
  Fmt.pr "Day 05\n";
  Fmt.pr "%d\n" min;
  (* let almanac = Almanac.seeds_to_ranges almanac in *)
  (* let locations = Almanac.to_destination' almanac in *)
  (* List.iter ~f:(fun (s, e) -> Fmt.pr "(%d,%d)" s e) locations; *)
  (* Fmt.pr "\n"; *)
  (* let min = *)
  (*   locations |> List.fold ~init:Int.max_value ~f:(fun acc (s, _) -> Int.min acc s) *)
  (* in *)
  (* Fmt.pr "%d\n" min; *)
  ()
;;

(*
   Solve part two with

   useRule :: Rule -> Interval -> ([Interval], [Interval], [Rule])
   useRule (Rule (Iv rl rh) d) (Iv xl xh) = (newResults, newVals, newRules)
   where newResults =
   filter legalInterval [ Iv (min xl rl) (min xh (rl - 1)) -- input below rule
                              , Iv ((max xl rl) + d) ((min xh rh) + d)] -- input within rule

   newVals = filter legalInterval [Iv (max xl (rh + 1)) (max xh rh)] -- input above rule
   newRules = filter legalRule [Rule (Iv (max (xh + 1) rl) (max xh rh)) d] -- rule above input

   useRules :: [Rule] -> [Interval] -> [Interval]
   useRules [] vals = vals
   useRules _ [] = []
   useRules (r@(Rule (Iv rl rh) _):rs) (v@(Iv xl xh):vs)
   | rh < xl = useRules rs (v:vs)
   | xh < rl = v : useRules (r:rs) vs
   | otherwise = newResults ++ (useRules (newRules ++ rs) (newVals ++ vs))
   where (newResults, newVals, newRules) = useRule r v

   legalInterval :: Interval -> Bool
   legalInterval (Iv l h) = l <= h

   legalRule :: Rule -> Bool
   legalRule (Rule iv _) = legalInterval iv
*)
