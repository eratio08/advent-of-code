import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import lib

fn input() {
  let input = lib.words_lines_trimmed("input/d6t")
  list.fold(input, dict.from_list([]), fn(cols, row) {
    list.index_fold(row, cols, fn(cols, val, i) {
      dict.upsert(cols, i, fn(col) {
        case col {
          Some(col) -> list.prepend(col, val)
          None -> [val]
        }
      })
    })
  })
  |> dict.to_list()
  |> list.map(fn(t) { t.1 })
  |> echo
}

pub fn p1() {
  input()
  |> list.fold(0, fn(sum, col) {
    let op = lib.value(list.first(col))
    let nums = list.drop(col, 1) |> list.try_map(int.parse)
    let assert Ok(nums) = nums

    calc(#(nums, op)) + sum
  })
}

fn calc(pair) {
  let #(nums, op) = pair
  case op {
    "+" -> int.sum(nums)
    "*" -> list.fold(nums, 1, fn(acc, n) { acc * n })
    _ -> panic as "unknown operator"
  }
}

fn input2() {
  let lines = lib.lines("input/d6t")
  let num_lines = list.take(lines, list.length(lines) - 1)
  let assert Ok(op_line) = list.last(lines)

  let ops = string.split(op_line, " ") |> list.filter(not_empty)

  num_lines
  |> list.map(string.to_graphemes)
  |> transpose([])
  |> chunk_by_sep_col([])
  |> list.filter(fn(chunk) {
    case chunk {
      [] -> False
      [first_col, ..] -> !is_all_spaces(first_col)
    }
  })
  |> list.map(cols_to_num)
  |> list.zip(ops)
}

fn not_empty(s) {
  !string.is_empty(s)
}

pub fn p2() {
  input2()
  |> list.map(calc)
  |> int.sum()
}

fn transpose(rows, acc) {
  case rows {
    [] | [[], ..] -> list.reverse(acc)
    _ -> {
      let heads = rows |> list.filter_map(list.first)
      let tails = rows |> list.map(list.drop(_, 1))
      transpose(tails, [heads, ..acc])
    }
  }
}

fn chunk_by_sep_col(cols, acc) {
  case cols {
    [] -> list.reverse(acc)
    [col, ..rest] -> {
      case acc {
        [] -> chunk_by_sep_col(rest, [[col]])
        [current, ..others] -> {
          let assert Ok(last_col) = list.first(current)
          let is_sep_col = is_all_spaces(col)
          let last_was_sep = is_all_spaces(last_col)
          case is_sep_col, last_was_sep {
            False, False -> chunk_by_sep_col(rest, [[col, ..current], ..others])
            _, _ -> chunk_by_sep_col(rest, [[col], current, ..others])
          }
        }
      }
    }
  }
}

fn is_all_spaces(col) {
  list.all(col, fn(c) { c == " " })
}

fn cols_to_num(columns) {
  columns
  |> list.reverse()
  |> list.map(col_to_num)
}

fn col_to_num(col) {
  col
  |> list.filter(fn(c) { c != " " })
  |> string.concat()
  |> int.parse()
  |> lib.value()
}
