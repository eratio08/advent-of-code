import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set
import gleam/string
import lib

type Machine {
  Machine(
    lights: Int,
    buttons: List(Int),
    buttons_num: List(List(Int)),
    joltage: List(Int),
  )
}

fn new_machine() -> Machine {
  Machine(lights: 0, buttons: [], buttons_num: [], joltage: [])
}

fn input() -> List(Machine) {
  lib.lines("input/d10t")
  |> list.map(fn(line) {
    line
    |> string.split(" ")
    |> list.fold(new_machine(), fn(m, part) {
      case part {
        "[" <> rest ->
          Machine(..m, lights: parse_lights(string.to_graphemes(rest), 0, 0))
        "(" <> rest -> {
          let #(buttons, buttons_num) = parse_button(string.to_graphemes(rest))
          let buttons = list.append(m.buttons, [buttons])
          let buttons_num = list.append(m.buttons_num, [buttons_num])
          Machine(..m, buttons: buttons, buttons_num: buttons_num)
        }
        "{" <> rest ->
          Machine(..m, joltage: parse_joltage(string.split(rest, ","), []))
        _ -> panic as "invalid part"
      }
    })
  })
}

fn parse_lights(parts, i, lights) -> Int {
  case parts {
    [] | ["]"] -> lights
    [a, ..rest] -> {
      let lights = case a {
        "." -> lights
        "#" -> int.bitwise_or(lights, int.bitwise_shift_left(1, i))
        _ -> panic as "invalid light"
      }
      parse_lights(rest, i + 1, lights)
    }
  }
}

fn parse_button(parts) -> #(Int, List(Int)) {
  let assert Ok(buttons) =
    parts
    |> list.filter(fn(c) { c != "," && c != ")" })
    |> list.try_map(int.parse)

  buttons
  |> list.fold(0, fn(buttons, button) {
    int.bitwise_or(buttons, int.bitwise_shift_left(1, button))
  })
  |> fn(b) { #(b, buttons) }
}

fn parse_joltage(parts, joltage) -> List(Int) {
  case parts {
    [] -> joltage
    [a] -> {
      let a = string.drop_end(a, 1)
      let assert Ok(num) = int.parse(a)
      list.append(joltage, [num])
    }
    [a, ..rest] -> {
      let assert Ok(num) = int.parse(a)
      parse_joltage(rest, list.append(joltage, [num]))
    }
  }
}

pub fn p1() {
  input()
  |> list.fold(0, fn(s, m) { bfs(m.lights, m.buttons) + s })
}

fn bfs(lights, buttons) {
  let solutions = set.from_list([0])
  bfs_rec(solutions, lights, buttons, 0)
}

fn bfs_rec(solutions, lights, buttons, iterations) {
  case set.contains(solutions, lights) {
    True -> iterations
    False -> {
      let solutions = press_buttons(solutions, buttons)
      bfs_rec(solutions, lights, buttons, iterations + 1)
    }
  }
}

fn press_buttons(solutions, buttons) {
  solutions
  |> set.to_list()
  |> list.flat_map(fn(solution) {
    buttons |> list.map(int.bitwise_exclusive_or(solution, _))
  })
  |> set.from_list()
}

// https://en.wikipedia.org/wiki/Integer_programming
// https://en.wikipedia.org/wiki/Gaussian_elimination
// Not my solution, https://github.com/ayoubzulfiqar/advent-of-code/blob/main/2025/Go/Day10/part_2.go
pub fn p2() {
  let machines = input()
  let parent = process.new_subject()

  machines
  |> list.index_map(fn(m, idx) {
    process.spawn(fn() {
      let result = solve_machine(m.joltage, m.buttons_num)
      process.send(parent, #(idx, result))
    })
  })

  let results =
    list.range(0, list.length(machines) - 1)
    |> list.fold(dict.new(), fn(acc, _) {
      let assert Ok(#(idx, result)) = process.receive(parent, 300_000)
      dict.insert(acc, idx, result)
    })

  let total =
    list.range(0, list.length(machines) - 1)
    |> list.fold(0, fn(sum, idx) {
      let assert Ok(val) = dict.get(results, idx)
      sum + val
    })

  total
}

type Matrix {
  Matrix(data: Dict(#(Int, Int), Int), rows: Int, cols: Int)
}

fn at(lst: List(a), idx: Int) -> Option(a) {
  case idx < 0 {
    True -> None
    False ->
      lst
      |> list.drop(idx)
      |> list.first()
      |> option.from_result()
  }
}

fn index_of(lst: List(a), elem: a) -> Option(Int) {
  lst
  |> list.index_fold(None, fn(acc, item, idx) {
    case acc {
      Some(_) -> acc
      None ->
        case item == elem {
          True -> Some(idx)
          False -> None
        }
    }
  })
}

fn matrix_get(m: Matrix, row: Int, col: Int) -> Int {
  dict.get(m.data, #(row, col)) |> result.unwrap(0)
}

fn matrix_set(m: Matrix, row: Int, col: Int, val: Int) -> Matrix {
  Matrix(..m, data: dict.insert(m.data, #(row, col), val))
}

fn build_matrix(buttons: List(List(Int)), joltages: List(Int)) -> Matrix {
  let num_buttons = list.length(buttons)
  let data =
    joltages
    |> list.index_fold(dict.new(), fn(matrix, counter, i) {
      buttons
      |> list.index_fold(matrix, fn(matrix, button, j) {
        let val = case list.contains(button, i) {
          True -> 1
          False -> 0
        }
        dict.insert(matrix, #(i, j), val)
      })
      |> dict.insert(#(i, num_buttons), counter)
    })

  Matrix(data: data, rows: list.length(joltages), cols: num_buttons)
}

// https://www.geeksforgeeks.org/dsa/gaussian-elimination/
fn gaussian_elimination(m: Matrix) -> #(List(Int), Matrix) {
  case m.rows {
    0 -> #([], m)
    _ -> do_elimination(m, 0, 0, [])
  }
}

fn do_elimination(
  mat: Matrix,
  row: Int,
  col: Int,
  pivot_cols: List(Int),
) -> #(List(Int), Matrix) {
  let n = mat.cols
  let m = mat.rows
  case col >= n || row >= m {
    True -> #(list.reverse(pivot_cols), mat)
    False -> {
      case find_pivot_row(mat, row, col, m) {
        None -> do_elimination(mat, row, col + 1, pivot_cols)
        Some(pivot_row) -> {
          let mat = swap_rows(mat, row, pivot_row)
          let mat = eliminate_below(mat, row, col)
          let pivot_val = matrix_get(mat, row, col)
          case pivot_val == 0 {
            True -> {
              do_elimination(mat, row, col + 1, pivot_cols)
            }
            False -> {
              let new_pivot_cols = [col, ..pivot_cols]
              do_elimination(mat, row + 1, col + 1, new_pivot_cols)
            }
          }
        }
      }
    }
  }
}

fn find_pivot_row(mat: Matrix, start_row: Int, col: Int, m: Int) -> Option(Int) {
  list.range(start_row, m - 1)
  |> list.find(fn(row) { matrix_get(mat, row, col) != 0 })
  |> option.from_result()
}

fn swap_rows(mat: Matrix, row1: Int, row2: Int) -> Matrix {
  case row1 == row2 {
    True -> mat
    False -> {
      list.range(0, mat.cols)
      |> list.fold(mat, fn(m, col) {
        let val1 = matrix_get(m, row1, col)
        let val2 = matrix_get(m, row2, col)
        m
        |> matrix_set(row1, col, val2)
        |> matrix_set(row2, col, val1)
      })
    }
  }
}

fn eliminate_below(mat: Matrix, pivot_row: Int, col: Int) -> Matrix {
  let pivot_val = matrix_get(mat, pivot_row, col)

  list.range(pivot_row + 1, mat.rows - 1)
  |> list.fold(mat, fn(m, row_idx) {
    let factor = matrix_get(m, row_idx, col)
    case factor == 0 {
      True -> m
      False ->
        list.range(col, m.cols)
        |> list.fold(m, fn(m2, j) {
          let val = matrix_get(m2, row_idx, j)
          let pivot_elem = matrix_get(m2, pivot_row, j)
          let new_val = val * pivot_val - pivot_elem * factor
          matrix_set(m2, row_idx, j, new_val)
        })
    }
  })
}

fn find_free_variables(pivot_cols: List(Int), num_vars: Int) -> List(Int) {
  list.range(0, num_vars - 1)
  |> list.filter(fn(i) { !list.contains(pivot_cols, i) })
}

fn solve_machine(joltages: List(Int), buttons: List(List(Int))) -> Int {
  let matrix = build_matrix(buttons, joltages)
  let #(pivot_cols, reduced_matrix) = gaussian_elimination(matrix)
  let free_vars = find_free_variables(pivot_cols, list.length(buttons))
  let max_joltage = list.fold(joltages, 0, int.max)

  let solutions =
    enumerate_solutions(
      free_vars,
      pivot_cols,
      reduced_matrix,
      list.length(buttons),
      max_joltage,
      buttons,
      joltages,
    )

  case solutions {
    [] -> 0
    _ ->
      solutions
      |> list.map(int.sum)
      |> list.fold(999_999_999, int.min)
  }
}

fn enumerate_solutions(
  free_vars: List(Int),
  pivot_cols: List(Int),
  reduced_matrix: Matrix,
  num_vars: Int,
  max_joltage: Int,
  buttons: List(List(Int)),
  joltages: List(Int),
) -> List(List(Int)) {
  case list.length(free_vars) {
    0 -> {
      case
        try_solution(
          [],
          free_vars,
          pivot_cols,
          reduced_matrix,
          num_vars,
          buttons,
          joltages,
        )
      {
        Some(sol) -> [sol]
        None -> []
      }
    }
    1 -> {
      let max_val = int.max(max_joltage * 3, 300)
      list.range(0, max_val)
      |> list.filter_map(fn(v) {
        try_solution(
          [v],
          free_vars,
          pivot_cols,
          reduced_matrix,
          num_vars,
          buttons,
          joltages,
        )
        |> option.to_result(Nil)
      })
    }
    2 -> {
      let max_val = int.max(max_joltage, 150)
      list.range(0, max_val)
      |> list.flat_map(fn(v1) {
        list.range(0, max_val)
        |> list.filter_map(fn(v2) {
          try_solution(
            [v1, v2],
            free_vars,
            pivot_cols,
            reduced_matrix,
            num_vars,
            buttons,
            joltages,
          )
          |> option.to_result(Nil)
        })
      })
    }
    3 -> {
      let max_val = 250
      list.range(0, max_val)
      |> list.flat_map(fn(v1) {
        list.range(0, max_val)
        |> list.flat_map(fn(v2) {
          list.range(0, max_val)
          |> list.filter_map(fn(v3) {
            try_solution(
              [v1, v2, v3],
              free_vars,
              pivot_cols,
              reduced_matrix,
              num_vars,
              buttons,
              joltages,
            )
            |> option.to_result(Nil)
          })
        })
      })
    }
    4 -> {
      let max_val = 50
      list.range(0, max_val)
      |> list.flat_map(fn(v1) {
        list.range(0, max_val)
        |> list.flat_map(fn(v2) {
          list.range(0, max_val)
          |> list.flat_map(fn(v3) {
            list.range(0, max_val)
            |> list.filter_map(fn(v4) {
              try_solution(
                [v1, v2, v3, v4],
                free_vars,
                pivot_cols,
                reduced_matrix,
                num_vars,
                buttons,
                joltages,
              )
              |> option.to_result(Nil)
            })
          })
        })
      })
    }
    _ -> []
  }
}

fn try_solution(
  free_values: List(Int),
  free_vars: List(Int),
  pivot_cols: List(Int),
  reduced_matrix: Matrix,
  num_vars: Int,
  buttons: List(List(Int)),
  joltages: List(Int),
) -> Option(List(Int)) {
  let solution =
    list.range(0, num_vars - 1)
    |> list.map(fn(i) {
      case index_of(free_vars, i) {
        Some(idx) ->
          case at(free_values, idx) {
            Some(val) -> val
            None -> 0
          }
        None -> 0
      }
    })

  case back_substitute(solution, pivot_cols, reduced_matrix, num_vars) {
    None -> None
    Some(solution) -> {
      case validate_solution(solution, buttons, joltages) {
        True -> Some(solution)
        False -> None
      }
    }
  }
}

fn back_substitute(
  solution: List(Int),
  pivot_cols: List(Int),
  reduced_matrix: Matrix,
  num_vars: Int,
) -> Option(List(Int)) {
  let num_pivot_rows = list.length(pivot_cols)

  list.range(0, num_pivot_rows - 1)
  |> list.reverse()
  |> list.fold(Some(solution), fn(result, row_idx) {
    case result {
      None -> None
      Some(sol) -> {
        case at(pivot_cols, row_idx) {
          None -> None
          Some(pivot_col) -> {
            let n = reduced_matrix.cols
            let constant = matrix_get(reduced_matrix, row_idx, n)

            let total =
              list.range(pivot_col + 1, int.min(num_vars - 1, n - 1))
              |> list.fold(constant, fn(acc, j) {
                let coeff = matrix_get(reduced_matrix, row_idx, j)
                case at(sol, j) {
                  None -> acc
                  Some(val) -> acc - coeff * val
                }
              })

            let pivot_val = matrix_get(reduced_matrix, row_idx, pivot_col)

            case pivot_val == 0 {
              True -> None
              False ->
                case total % pivot_val == 0 {
                  False -> None
                  True -> {
                    let val = total / pivot_val
                    case val < 0 {
                      True -> None
                      False ->
                        Some(
                          list.index_map(sol, fn(v, idx) {
                            case idx == pivot_col {
                              True -> val
                              False -> v
                            }
                          }),
                        )
                    }
                  }
                }
            }
          }
        }
      }
    }
  })
}

fn validate_solution(
  solution: List(Int),
  buttons: List(List(Int)),
  joltages: List(Int),
) -> Bool {
  let num_counters = list.length(joltages)

  list.range(0, num_counters - 1)
  |> list.all(fn(counter_idx) {
    let total =
      buttons
      |> list.index_fold(0, fn(acc, button, button_idx) {
        case at(solution, button_idx) {
          Some(presses) ->
            case presses > 0 && list.contains(button, counter_idx) {
              True -> acc + presses
              False -> acc
            }
          None -> acc
        }
      })
    case at(joltages, counter_idx) {
      Some(target) -> total == target
      None -> False
    }
  })
}
