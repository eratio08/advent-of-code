import gleam/dict.{type Dict}
import gleam/option

pub type Grid(a) {
  Grid(Dict(#(Int, Int), a), Int, Int)
}

pub fn get_cell(grid: Grid(a), i: Int, j: Int) -> option.Option(a) {
  let Grid(cells, n, m) = grid
  case i, j {
    i, j if i < 0 || j < 0 -> option.None
    i, j if i > n || j > m -> option.None
    i, j ->
      case dict.get(cells, #(i, j)) {
        Ok(value) -> option.Some(value)
        Error(_) -> option.None
      }
  }
}

pub fn set_cell(grid: Grid(a), i: Int, j: Int, a: a) -> Grid(a) {
  let Grid(cells, n, m) = grid

  case i, j {
    i, j if i < 0 || j < 0 -> grid
    i, j if i > n || j > m -> grid
    i, j -> Grid(dict.insert(cells, #(i, j), a), n, m)
  }
}

pub fn n(grid: Grid(a)) -> Int {
  let Grid(_, n, _) = grid
  n
}

pub fn m(grid: Grid(a)) -> Int {
  let Grid(_, _, m) = grid
  m
}
