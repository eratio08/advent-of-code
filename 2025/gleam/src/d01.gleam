import gleam/int
import gleam/list
import gleam/string
import lib

type Spin {
  Left(Int)
  Right(Int)
}

fn input() {
  lib.lines("input/d1")
  |> list.map(fn(line) {
    let direction = string.slice(line, 0, 1)
    let distance =
      string.slice(line, 1, string.length(line)) |> int.parse() |> lib.value()
    case direction {
      "L" -> Left(distance)
      "R" -> Right(distance)
      _ -> panic as "unable to parse spin"
    }
  })
}

pub fn p1() {
  let #(_, nz) =
    input()
    |> list.fold(#(50, 0), fn(state, spin) {
      let #(pos, nz) = state
      let pos = case spin {
        Left(distance) ->
          case { pos - distance } % 100 {
            x if x < 0 -> 100 + x
            x -> x
          }
        Right(distance) -> { pos + distance } % 100
      }
      case pos {
        0 -> #(pos, nz + 1)
        _ -> #(pos, nz)
      }
    })
  nz
}

pub fn p2() {
  let #(_, nz) =
    input()
    |> list.fold(#(50, 0), step)
  nz
}

fn step(state, spin) {
  case spin {
    Left(0) -> state
    Right(0) -> state
    spin -> {
      let #(pos, nz) = state
      let #(pos, spin) = case spin {
        Left(n) -> #(pos - 1, Left(n - 1))
        Right(n) -> #(pos + 1, Right(n - 1))
      }
      let pos = case pos {
        pos if pos < 0 -> 99
        pos if pos > 99 -> 0
        _ -> pos
      }

      case pos {
        0 -> step(#(pos, nz + 1), spin)
        pos -> step(#(pos, nz), spin)
      }
    }
  }
}
