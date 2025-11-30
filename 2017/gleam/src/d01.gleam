import gleam/list
import lib

pub fn p1() {
  case lib.ints("input/d1") {
    [] -> panic as "input was empty"
    [h, ..tail] -> p1_rec(h, h, tail, 0)
  }
}

fn p1_rec(head, a, rest, sum) {
  case rest {
    [] -> sum
    [b] ->
      case b, head {
        a, b if a == b -> sum + a
        _, _ -> sum
      }
    [b, ..r] ->
      case a, b {
        a, b if a == b -> p1_rec(head, b, r, sum + a)
        _, _ -> p1_rec(head, b, r, sum)
      }
  }
}

pub fn p2() {
  let ints = lib.ints("input/d1")
  let len = list.length(ints)
  let windows = len / 2

  p2_rec(len, windows, 0, ints, 0)
}

fn p2_rec(len, window, sum, ls, i) {
  case i {
    i if i >= len -> sum
    i -> {
      let a = nth(ls, i)
      let b = nth(ls, { i + window } % len)
      case a, b {
        a, b if a == b -> p2_rec(len, window, sum + a, ls, i + 1)
        _, _ -> p2_rec(len, window, sum, ls, i + 1)
      }
    }
  }
}

fn nth(ls, n) {
  nth_rec(ls, 0, n)
}

fn nth_rec(tail, i, n) {
  case tail, i {
    [], _ -> panic
    [h, ..], i if i == n -> h
    [_, ..rest], i -> nth_rec(rest, i + 1, n)
  }
}
