import gleam/list
import gleam/option.{Some}
import grid.{Grid} as gr
import lib

fn inputs() {
  lib.read_grid("input/d4")
}

pub fn p1() {
  inputs() |> process_grid()
}

fn process_grid(grid) {
  count_accessible_rolls(grid, 0, 0, 0)
}

fn count_accessible_rolls(grid, i, j, count) {
  let Grid(_, n, m) = grid
  case i >= n {
    True -> count
    False ->
      case j >= m {
        True -> count_accessible_rolls(grid, i + 1, 0, count)
        False -> {
          let new_count = case gr.get_cell(grid, i, j) {
            Some("@") -> {
              let neighbor_count = count_neighbors(grid, i, j)
              case neighbor_count < 4 {
                True -> count + 1
                False -> count
              }
            }
            _ -> count
          }
          count_accessible_rolls(grid, i, j + 1, new_count)
        }
      }
  }
}

const directions = [
  // up
  #(0, 1),
  // up right
  #(1, 1),
  // right
  #(1, 0),
  // down right
  #(-1, 1),
  // down
  #(0, -1),
  // down left
  #(-1, -1),
  // left
  #(-1, 0),
  // up left
  #(1, -1),
]

fn count_neighbors(grid, i, j) {
  directions
  |> list.fold(0, fn(count, offset) {
    let #(dx, dy) = offset
    let x = i + dx
    let y = j + dy

    case gr.get_cell(grid, x, y) {
      Some("@") -> count + 1
      _ -> count
    }
  })
}

pub fn p2() {
  inputs() |> process_grid_2(0)
}

fn process_grid_2(grid, total_removed) {
  let #(new_grid, removed_count) = remove_accessible_rolls(grid)

  case removed_count > 0 {
    True -> process_grid_2(new_grid, total_removed + removed_count)
    False -> total_removed
  }
}

fn remove_accessible_rolls(grid) {
  find_and_remove_accessible(grid, 0, 0, 0)
}

fn find_and_remove_accessible(grid, i, j, count) {
  let Grid(_, n, m) = grid
  case i >= n {
    True -> #(grid, count)
    False ->
      case j >= m {
        True -> find_and_remove_accessible(grid, i + 1, 0, count)
        False -> {
          case gr.get_cell(grid, i, j) {
            Some("@") -> try_remove(grid, i, j, count)
            _ -> find_and_remove_accessible(grid, i, j + 1, count)
          }
        }
      }
  }
}

fn try_remove(grid, i, j, count) {
  case count_neighbors(grid, i, j) < 4 {
    True -> {
      let new_grid = gr.set_cell(grid, i, j, ".")
      find_and_remove_accessible(new_grid, i, j + 1, count + 1)
    }
    False -> find_and_remove_accessible(grid, i, j + 1, count)
  }
}
