import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import lib

type Tile =
  #(Int, Int)

type Line =
  #(Tile, Tile)

type Box =
  #(Int, Tile, Tile)

type Polygon =
  List(Line)

fn input() -> List(Tile) {
  lib.lines("input/d9")
  |> list.map(fn(line) {
    let assert Ok([x, y]) = line |> string.split(",") |> list.try_map(int.parse)
    #(x, y)
  })
}

pub fn p1() {
  input()
  |> areas()
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.first()
  |> result.unwrap(0)
}

fn areas(tiles) {
  areas_rec(tiles, [])
}

fn areas_rec(tiles, boxes) -> List(Int) {
  case tiles {
    [] -> boxes
    [tile, ..rest] -> {
      let areas =
        rest
        |> list.map(fn(tile2) {
          let #(x1, y1) = tile
          let #(x2, y2) = tile2
          let a = int.absolute_value(x2 - x1) + 1
          let b = int.absolute_value(y2 - y1) + 1
          a * b
        })

      areas_rec(rest, list.append(boxes, areas))
    }
  }
}

// https://en.wikipedia.org/wiki/Point_in_polygon
// https://en.wikipedia.org/wiki/Ray_casting
pub fn p2() {
  let input = input()
  let boxes = input |> boxes()

  input
  |> build_polygon()
  |> find_box(boxes)
  |> option.unwrap(-1)
}

fn find_box(polygon, boxes) -> option.Option(Int) {
  find_box_memo(polygon, boxes, dict.from_list([]))
}

fn find_box_memo(polygon, boxes, memo) -> option.Option(Int) {
  case boxes {
    [] -> option.None
    [box, ..rest] -> {
      case box_is_all_green_optimized(box, polygon, memo) {
        #(True, _) -> option.Some(box.0)
        #(False, memo) -> find_box_memo(polygon, rest, memo)
      }
    }
  }
}

fn build_polygon(tiles: List(Tile)) -> Polygon {
  case tiles {
    [] -> []
    [first, ..] -> build_polygon_rec(tiles, first, [])
  }
}

fn build_polygon_rec(tiles: List(Tile), first: Tile, acc: List(Line)) -> Polygon {
  case tiles {
    [] -> acc
    [last] -> list.reverse([#(last, first), ..acc])
    [current, next, ..rest] -> {
      build_polygon_rec([next, ..rest], first, [#(current, next), ..acc])
    }
  }
}

fn boxes(tiles) {
  boxes_rec(tiles, []) |> list.sort(fn(a, b) { int.compare(b.0, a.0) })
}

fn boxes_rec(tiles, boxes) -> List(Box) {
  case tiles {
    [] -> boxes
    [tile, ..rest] -> {
      let areas =
        rest
        |> list.map(fn(tile2) {
          let #(x1, y1) = tile
          let #(x2, y2) = tile2
          let a = int.absolute_value(x2 - x1) + 1
          let b = int.absolute_value(y2 - y1) + 1
          #(a * b, tile, tile2)
        })

      boxes_rec(rest, list.append(boxes, areas))
    }
  }
}

// fn box_is_all_green(
//   box: Box,
//   polygon: Polygon,
//   memo,
// ) -> #(Bool, dict.Dict(Tile, Bool)) {
//   let #(_, corner1, corner2) = box
//   let #(x1, y1) = corner1
//   let #(x2, y2) = corner2
//
//   case x1 == x2 || y1 == y2 {
//     True -> #(False, memo)
//     False -> {
//       let min_x = int.min(x1, x2)
//       let max_x = int.max(x1, x2)
//       let min_y = int.min(y1, y2)
//       let max_y = int.max(y1, y2)
//
//       list.range(min_x, max_x)
//       |> list.fold_until(#(True, memo), fn(s, x) {
//         case s.0 {
//           False -> list.Stop(s)
//           True -> {
//             list.range(min_y, max_y)
//             |> list.fold_until(s, fn(s, y) {
//               case s.0 {
//                 False -> list.Stop(s)
//                 True -> {
//                   let #(green, memo) = is_green(#(x, y), polygon, s.1)
//                   list.Continue(#(green && s.0, memo))
//                 }
//               }
//             })
//             |> list.Continue
//           }
//         }
//       })
//     }
//   }
// }

fn is_green(tile, polygon: Polygon, memo) {
  case dict.get(memo, tile) {
    Ok(green) -> #(green, memo)
    Error(_) -> {
      let green = case on_line(tile, polygon) {
        True -> True
        False -> point_in_polygon(tile, polygon)
      }
      let memo = dict.insert(memo, tile, green)
      #(green, memo)
    }
  }
}

fn point_in_polygon(point: Tile, polygon: Polygon) {
  let #(px, py) = point

  polygon
  |> list.filter(fn(line) { ray_intersects_line(px, py, line) })
  |> list.length()
  |> fn(n) { n % 2 == 1 }
}

// horizontal ray to the right
fn ray_intersects_line(px: Int, py: Int, line: Line) {
  let #(#(x1, y1), #(x2, y2)) = line
  case { y1 > py } == { y2 > py } {
    True -> False
    False -> {
      case y1 == py && y2 == py {
        True -> False
        False -> {
          // https://en.wikipedia.org/wiki/Linear_interpolation solved for px
          { x1 + { py - y1 } * { x2 - x1 } / { y2 - y1 } } >= px
        }
      }
    }
  }
}

fn on_line(point: Tile, lines: List(Line)) {
  lines |> list.any(fn(edge) { on_edge(point, edge) })
}

fn on_edge(point: Tile, line: Line) -> Bool {
  let #(px, py) = point
  let #(#(x1, y1), #(x2, y2)) = line
  case x1 == x2 {
    True -> {
      px == x1 && py >= int.min(y1, y2) && py <= int.max(y1, y2)
    }
    False -> {
      py == y1 && px >= int.min(x1, x2) && px <= int.max(x1, x2)
    }
  }
}

// not my idea, taken from https://github.com/Adz-ai/AdventOfCode2025/blob/main/src/main/java/aoc/day09/RectilinearPolygon.java
// could not get mine to finish, this one is much faster
fn box_is_all_green_optimized(
  box: Box,
  polygon: Polygon,
  memo: Dict(Tile, Bool),
) {
  let #(_, p1, p2) = box
  let #(x1, y1) = p1
  let #(x2, y2) = p2

  case x1 == x2 || y1 == y2 {
    True -> #(False, memo)
    False -> {
      let min_x = int.min(x1, x2)
      let max_x = int.max(x1, x2)
      let min_y = int.min(y1, y2)
      let max_y = int.max(y1, y2)
      let corners = [p1, p2, #(min_x, max_y), #(max_x, min_y)]
      let #(all_green, memo) = check_all_green(corners, polygon, memo)
      case all_green {
        False -> #(False, memo)
        True -> {
          case box_crosses_polygon(polygon, #(min_x, max_x, min_y, max_y)) {
            True -> #(False, memo)
            False -> #(True, memo)
          }
        }
      }
    }
  }
}

fn box_crosses_polygon(polygon: Polygon, box) -> Bool {
  polygon
  |> list.any(fn(line) { box_crosses_polygon_line(line, box) })
}

fn box_crosses_polygon_line(line: Line, box) -> Bool {
  let #(#(x1, y1), #(x2, y2)) = line
  let #(min_x, max_x, min_y, max_y) = box

  case x1 == x2 {
    True -> {
      let overlaps =
        int.max(int.min(y1, y2), min_y) < int.min(int.max(y1, y2), max_y)
      min_x < x1 && x1 < max_x && overlaps
    }
    False -> {
      let overlaps =
        int.max(int.min(x1, x2), min_x) < int.min(int.max(x1, x2), max_x)
      min_y < y1 && y1 < max_y && overlaps
    }
  }
}

fn check_all_green(tiles, polygon: Polygon, memo) {
  list.fold_until(tiles, #(True, memo), fn(state, tile) {
    case state.0 {
      False -> list.Stop(state)
      True -> list.Continue(is_green(tile, polygon, state.1))
    }
  })
}
