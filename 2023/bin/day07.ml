open Core

module Card = struct
  type t =
    | A
    | K
    | Q
    | J
    | T
    | Nine
    | Eight
    | Seven
    | Six
    | Five
    | Four
    | Three
    | Two

  let strength = function
    | A -> 14
    | K -> 13
    | Q -> 12
    | J -> 11
    | T -> 10
    | Nine -> 9
    | Eight -> 8
    | Seven -> 7
    | Six -> 6
    | Five -> 5
    | Four -> 4
    | Three -> 3
    | Two -> 2
  ;;

  let strength' = function
    | J -> 1
    | t -> strength t
  ;;

  let compare t1 t2 = strength t1 - strength t2
  let compare' t1 t2 = strength' t1 - strength' t2

  exception Invalid_card of char

  let of_char = function
    | 'A' -> A
    | 'K' -> K
    | 'Q' -> Q
    | 'J' -> J
    | 'T' -> T
    | '9' -> Nine
    | '8' -> Eight
    | '7' -> Seven
    | '6' -> Six
    | '5' -> Five
    | '4' -> Four
    | '3' -> Three
    | '2' -> Two
    | c -> raise (Invalid_card c)
  ;;
end

module IntMap = Map.Make (Int)

module HandType = struct
  type t =
    | FiveOfAKind
    | FourOfAKind
    | FullHouse
    | ThreeOfAKind
    | TwoPair
    | OnePair
    | HighCard

  let strength = function
    | FiveOfAKind -> 7
    | FourOfAKind -> 6
    | FullHouse -> 5
    | ThreeOfAKind -> 4
    | TwoPair -> 3
    | OnePair -> 2
    | HighCard -> 1
  ;;

  let compare t1 t2 = strength t1 - strength t2

  exception Invalid_count of int
  exception Invalid_combination of int * int

  let of_cards cards =
    let counts =
      List.fold cards ~init:IntMap.empty ~f:(fun cnts card ->
        Map.update cnts (Card.strength card) ~f:(fun cnt ->
          Option.value cnt ~default:0 |> ( + ) 1))
    in
    let max_count counts =
      Map.data counts |> List.max_elt ~compare:Int.compare |> Option.value_exn
    in
    match Map.length counts with
    | 1 -> FiveOfAKind
    | 2 -> if max_count counts = 4 then FourOfAKind else FullHouse
    | 3 -> if max_count counts = 3 then ThreeOfAKind else TwoPair
    | 4 -> OnePair
    | 5 -> HighCard
    | n -> raise (Invalid_count n)
  ;;

  let of_cards' cards =
    let counts =
      List.fold cards ~init:IntMap.empty ~f:(fun cnts card ->
        Map.update cnts (Card.strength' card) ~f:(fun cnt ->
          Option.value cnt ~default:0 |> ( + ) 1))
    in
    let disjoint_count = Map.length counts in
    let max_count =
      Map.filter_keys counts ~f:(fun k -> k = 1 |> not)
      |> Map.data
      |> List.max_elt ~compare:Int.compare
      |> Option.value ~default:5
    in
    let j_count = Map.find counts 1 |> Option.value ~default:0 in
    let rec determine disjoint_count max_count j_count =
      match disjoint_count, j_count with
      | 1, 0 | 1, 5 -> FiveOfAKind
      | 2, 0 -> if max_count = 4 then FourOfAKind else FullHouse
      | 2, n -> determine (disjoint_count - 1) (max_count + n) 0
      | 3, 0 -> if max_count = 3 then ThreeOfAKind else TwoPair
      | 3, n -> determine (disjoint_count - 1) (max_count + n) 0
      | 4, 0 -> OnePair
      | 4, n -> determine (disjoint_count - 1) (max_count + n) 0
      | 5, 0 -> HighCard
      | 5, n -> determine (disjoint_count - 1) (max_count + n) 0
      | n, j -> raise (Invalid_combination (n, j))
    in
    determine disjoint_count max_count j_count
  ;;
end

module Hand = struct
  type t =
    { cards : Card.t list
    ; handtype : HandType.t
    ; bid : int
    }

  let compare cmpfn t1 t2 =
    let compare_by_cards cs1 cs2 =
      List.zip_exn cs1 cs2
      |> List.find_map ~f:(fun (c1, c2) ->
        let cmp = cmpfn c1 c2 in
        let not_equal = Int.equal cmp 0 |> not in
        Option.some_if not_equal cmp)
    in
    let cmp = HandType.compare t1.handtype t2.handtype in
    match cmp with
    | 0 -> compare_by_cards t1.cards t2.cards |> Option.value ~default:0
    | n -> n
  ;;

  let cards_and_bid line =
    let cards =
      String.to_list line |> fun cs -> List.take cs 5 |> List.map ~f:Card.of_char
    in
    let bid =
      String.to_list line |> fun cs -> List.drop cs 6 |> String.of_list |> Int.of_string
    in
    cards, bid
  ;;

  let of_string line =
    let cards, bid = cards_and_bid line in
    let handtype = HandType.of_cards cards in
    { cards; handtype; bid }
  ;;

  let of_string' line =
    let cards, bid = cards_and_bid line in
    let handtype = HandType.of_cards' cards in
    { cards; handtype; bid }
  ;;

  let bid t = t.bid
end

let () =
  Fmt.pr "Day 7\n";
  let lines = Advent.Input.read_lines "input/day07" in
  let hands =
    List.map lines ~f:Hand.of_string |> List.sort ~compare:(Hand.compare Card.compare)
  in
  let total_winnings =
    List.foldi hands ~init:0 ~f:(fun i sum hand ->
      let rank = i + 1 in
      let winning = rank * Hand.bid hand in
      winning + sum)
  in
  Fmt.pr "%d\n" total_winnings;
  (* *)
  let hands =
    List.map lines ~f:Hand.of_string' |> List.sort ~compare:(Hand.compare Card.compare')
  in
  let total_winnings =
    List.foldi hands ~init:0 ~f:(fun i sum hand ->
      let rank = i + 1 in
      let winning = rank * Hand.bid hand in
      winning + sum)
  in
  Fmt.pr "%d\n" total_winnings
;;
