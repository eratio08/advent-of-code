import gleam/int
import gleam/list
import gleam/string
import lib

fn inputs() {
  lib.line_ints("input/d3t")
}

pub fn p1() {
  inputs()
  |> list.fold(0, fn(s, bank) { s + enable_bank(bank, 2) })
}

pub fn enable_bank(bank, n) {
  list.fold(bank, [], fn(enabled, battery) {
    let enabled = list.append(enabled, [battery])
    case list.length(enabled) {
      len if len > n -> {
        reorder_higher(enabled)
        |> list.take(n)
      }
      _ -> enabled
    }
  })
  |> list.map(int.to_string)
  |> string.concat
  |> int.parse
  |> lib.value()
}

fn reorder_higher(enabled) {
  case enabled {
    [] -> []
    [_] -> enabled
    [a, b, ..rest] ->
      case a < b {
        True -> list.prepend(rest, b)
        False -> list.prepend(reorder_higher(list.prepend(rest, b)), a)
      }
  }
}

pub fn p2() {
  inputs()
  |> list.fold(0, fn(n, bank) { n + enable_bank(bank, 12) })
}
