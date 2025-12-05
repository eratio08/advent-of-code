import gleam/int
import gleam/list

import gleam/string
import lib

fn inputs() {
  let lines = lib.lines("input/d5")
  let is_empty = fn(l) { l != "" }
  let id_ranges =
    lines
    |> list.take_while(is_empty)
    |> list.map(fn(l) {
      case string.split(l, on: "-") {
        [a, b] -> {
          let a = int.parse(a) |> lib.value()
          let b = int.parse(b) |> lib.value()
          #(a, b)
        }
        _ -> panic as "something is off"
      }
    })
  let ids =
    lines
    |> list.drop_while(is_empty)
    |> list.drop(1)
    |> list.map(fn(id) { int.parse(id) |> lib.value() })

  #(id_ranges, ids)
}

pub fn p1() {
  let #(ranges, ids) = inputs()
  ids
  |> list.fold(0, fn(s, id) {
    case is_fresh(ranges, id) {
      True -> s + 1
      False -> s
    }
  })
}

fn is_fresh(ranges, n) {
  ranges |> list.any(contains(_, n))
}

fn contains(range, n) {
  case range {
    #(a, b) if a <= n && n <= b -> True
    _ -> False
  }
}

pub fn p2() {
  let #(ranges, _) = inputs()

  let sorted = list.sort(ranges, fn(a, b) { int.compare(a.0, b.0) })
  list.fold(sorted, [], fn(acc, range) {
    case acc {
      [] -> [range]
      [last, ..rest] -> {
        case do_overlap(last, range) {
          True -> [merge(last, range), ..rest]
          False -> [range, ..acc]
        }
      }
    }
  })
  |> list.fold(0, fn(total, range) {
    let #(start, end) = range
    // inclusive range
    let size = end - start + 1
    total + size
  })
}

fn do_overlap(r1, r2) {
  let #(_, e1) = r1
  let #(s2, _) = r2
  e1 >= s2
}

fn merge(r1, r2) {
  let #(s1, e1) = r1
  let #(s2, e2) = r2
  #(int.min(s1, s2), int.max(e1, e2))
}
