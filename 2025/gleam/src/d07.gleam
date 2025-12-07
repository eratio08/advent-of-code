import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{Some}
import gleam/result
import grid as gr
import lib

type Acc {
  Acc(splits: Int, beams: Dict(Int, Int))
}

fn input() {
  lib.read_grid("input/d7t")
}

fn get_beams(beams, col) {
  dict.get(beams, col) |> result.unwrap(0)
}

fn add_beams(beams, col, cnt) {
  let current = get_beams(beams, col)
  dict.insert(beams, col, current + cnt)
}

fn process_row(acc: Acc, y, grid) {
  let n = gr.n(grid)

  list.fold(list.range(0, n - 1), acc, fn(acc, x) {
    let v = gr.get_cell(grid, x, y)
    let cnt = get_beams(acc.beams, x)

    case v {
      Some("S") -> {
        Acc(..acc, beams: dict.insert(acc.beams, x, 1))
      }

      Some("^") if cnt > 0 -> {
        let new_beams =
          acc.beams
          |> add_beams(x - 1, cnt)
          |> add_beams(x + 1, cnt)
          // the particle leaves the column after the split
          |> dict.insert(x, 0)

        Acc(splits: acc.splits + 1, beams: new_beams)
      }

      _ -> acc
    }
  })
}

pub fn p1() {
  let grid = input()
  let m = gr.m(grid)

  list.fold(list.range(0, m - 1), Acc(splits: 0, beams: dict.new()), fn(acc, y) {
    process_row(acc, y, grid)
  }).splits
}

pub fn p2() {
  let grid = input()
  let m = gr.m(grid)

  list.fold(list.range(0, m - 1), Acc(splits: 0, beams: dict.new()), fn(acc, y) {
    process_row(acc, y, grid)
  })
  |> fn(acc) { acc.beams }
  |> dict.fold(0, fn(sum, _l, count) { sum + count })
}
