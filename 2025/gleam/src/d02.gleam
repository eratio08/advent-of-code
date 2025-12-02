import gleam/int
import gleam/list
import gleam/string
import lib

fn input() {
  lib.read_file("input/d2")
  |> string.split(on: ",")
  |> list.map(fn(s) {
    let s = string.trim(s)
    case string.split(s, on: "-") {
      [a, b] -> #(lib.value(int.parse(a)), lib.value(int.parse(b)))
      _ -> panic as "unable to parse input"
    }
  })
}

pub fn p1() {
  input()
  |> list.fold(0, fn(s, range) {
    let #(start, end) = range
    p1_rec(start, end, s)
  })
}

fn p1_rec(i, end, ids) {
  case i {
    i if i > end -> ids
    i -> {
      let s = int.to_string(i)
      let l = string.length(s)
      case l % 2 {
        0 -> {
          // repeated once
          let repeated = string.repeat(string.slice(s, 0, l / 2), times: 2)
          case repeated == s {
            True -> p1_rec(i + 1, end, ids + i)
            False -> p1_rec(i + 1, end, ids)
          }
        }
        _ -> p1_rec(i + 1, end, ids)
      }
    }
  }
}

pub fn p2() {
  input()
  |> list.fold(0, fn(s, range) {
    let #(start, end) = range
    p2_rec(start, end, s)
  })
}

fn p2_rec(i, end, ids) {
  case i {
    i if i > end -> ids
    i -> {
      let s = int.to_string(i)
      let l = string.length(s)
      p2_rec(i + 1, end, find_repeating(1, l, s, i, ids))
    }
  }
}

fn find_repeating(i, l, s, id, ids) {
  case i {
    i if i > l / 2 -> ids
    i -> {
      case l % i {
        0 -> {
          // repeated many
          let repeated = string.repeat(string.slice(s, 0, i), times: l / i)
          case repeated == s {
            True -> ids + id
            False -> find_repeating(i + 1, l, s, id, ids)
          }
        }
        _ -> find_repeating(i + 1, l, s, id, ids)
      }
    }
  }
}
