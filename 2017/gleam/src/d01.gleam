import gleam/result
import lib

pub fn p1() {
  use ints <- result.try(lib.ints("input/d1"))
  case ints {
    [] -> Error(Nil)
    [h, ..tail] -> Ok(rec(h, h, tail, 0))
  }
}

fn rec(head, a, rest, sum) {
  case rest {
    [] -> sum
    [b] ->
      case b, head {
        a, b if a == b -> sum + a
        _, _ -> sum
      }
    [b, ..r] ->
      case a, b {
        a, b if a == b -> rec(head, b, r, sum + a)
        _, _ -> rec(head, b, r, sum)
      }
  }
}

pub fn p2() {
  Ok(0)
}
