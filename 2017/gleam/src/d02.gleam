import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import lib

fn input() -> List(List(Int)) {
  lib.lines("input/d2")
  |> list.map(fn(l) { string.split(l, on: "\t") })
  |> list.map(fn(str) { lib.value(list.try_map(str, fn(s) { int.parse(s) })) })
}

pub fn p1() {
  let rows = input()
  use sum, row <- list.fold(rows, 0)
  let #(min, max) = {
    use #(min, max), n <- list.fold(row, #(0, 0))
    let min = case min {
      0 -> n
      min if n < min -> n
      _ -> min
    }
    let max = case max {
      0 -> n
      max if n > max -> n
      _ -> max
    }
    #(min, max)
  }
  sum + int.absolute_value(min - max)
}

pub fn p2() {
  input()
  |> list.fold(0, fn(s, row) { s + even_divs(row, 0) })
}

fn even_div(x, ns) {
  case ns {
    [] -> None
    [h, ..tail] -> {
      let #(a, b) = case x, h {
        x, h if x > h -> #(x, h)
        x, h if x < h -> #(h, x)
        _, _ -> #(x, h)
      }
      case a % b {
        0 -> Some(a / b)
        _ -> even_div(x, tail)
      }
    }
  }
}

fn even_divs(row, sum) -> Int {
  case row {
    [] -> sum
    [x, ..rest] ->
      case even_div(x, rest) {
        None -> even_divs(rest, sum)
        Some(n) -> even_divs(rest, sum + n)
      }
  }
}
