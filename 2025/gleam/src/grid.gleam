import gleam/dict.{type Dict}
import gleam/list
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

pub fn in_grid(grid: Grid(a), i: Int, j: Int) -> Bool {
  let Grid(_, n, m) = grid
  case i, j {
    i, j if i < 0 || j < 0 -> False
    i, j if i > n || j > m -> False
    _, _ -> True
  }
}

// pub fn iter(grid: Grid(a), f: fn(#(Int, Int), a) -> b) -> Grid(b) {
//   todo
// }

pub fn fold(grid: Grid(a), s, f: fn(s, #(Int, Int), a) -> s) -> s {
  let Grid(_, n, m) = grid
  list.fold(list.range(0, m - 1), s, fn(s, j) {
    list.fold(list.range(0, n - 1), s, fn(s, i) {
      let assert option.Some(v) = get_cell(grid, i, j)
      f(s, #(i, j), v)
    })
  })
}
