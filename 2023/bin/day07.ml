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

  let compare t1 t2 = strength t1 - strength t2
  let equal t1 t2 = compare t1 t2 = 0

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
end

module Hand = struct
  type t =
    { cards : Card.t list
    ; handtype : HandType.t
    ; bid : int
    }

  let compare t1 t2 =
    let compare_by_cards cs1 cs2 =
      List.zip_exn cs1 cs2
      |> List.find_map ~f:(fun (c1, c2) ->
        let cmp = Card.compare c1 c2 in
        Option.some_if (Int.equal cmp 0 |> not) cmp)
    in
    let cmp = HandType.compare t1.handtype t2.handtype in
    match cmp with
    | 0 -> compare_by_cards t1.cards t2.cards |> Option.value ~default:0
    | n -> n
  ;;

  let of_string line =
    let cards =
      String.to_list line |> fun cs -> List.take cs 5 |> List.map ~f:Card.of_char
    in
    let bid =
      String.to_list line |> fun cs -> List.drop cs 6 |> String.of_list |> Int.of_string
    in
    let handtype = HandType.of_cards cards in
    { cards; handtype; bid }
  ;;

  let bid t = t.bid
end

let () =
  Fmt.pr "Day 7\n";
  let lines = Advent.Input.read_lines "input/day07" in
  let hands = List.map lines ~f:Hand.of_string |> List.sort ~compare:Hand.compare in
  let total_winnings =
    List.foldi hands ~init:0 ~f:(fun i sum hand ->
      let rank = i + 1 in
      let winning = rank * Hand.bid hand in
      winning + sum)
  in
  Fmt.pr "%d\n" total_winnings;
  ()
;;
