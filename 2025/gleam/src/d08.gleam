import gleam/dict
import gleam/int
import gleam/list
import gleam/string
import lib
import uf

type Point =
  #(Int, Int, Int)

type Edge =
  #(Int, Point, Point)

fn input() -> List(Point) {
  lib.lines("input/d8t")
  |> list.map(fn(line) {
    let assert [x, y, z] = line |> string.split(on: ",")
    let assert Ok(x) = int.parse(x)
    let assert Ok(y) = int.parse(y)
    let assert Ok(z) = int.parse(z)
    #(x, y, z)
  })
}

fn compare(p: Edge, q: Edge) {
  int.compare(p.0, q.0)
}

pub fn p1() {
  let points = input()
  let con_cnt = case list.length(points) {
    // "..making the ten shortest connections"
    20 -> 10
    // "..connect together the 1000"
    _ -> 1000
  }

  edges(points)
  |> list.sort(compare)
  |> list.take(con_cnt)
  |> list.fold(uf.new(points), fn(djs, edge) {
    let #(_, p1, p2) = edge
    uf.union(djs, p1, p2)
  })
  |> sizes(points)
  |> list.sort(by: fn(a, b) { int.compare(b, a) })
  |> list.take(3)
  |> list.fold(1, fn(p, size) { p * size })
}

fn distance(p1: Point, p2: Point) {
  let #(x1, y1, z1) = p1
  let #(x2, y2, z2) = p2
  let dx = int.absolute_value(x2 - x1)
  let dy = int.absolute_value(y2 - y1)
  let dz = int.absolute_value(z2 - z1)
  dx * dx + dy * dy + dz * dz
}

fn edges(points) {
  edges_rec(points, [])
}

fn edges_rec(points, edges) {
  case points {
    [] -> edges
    [p, ..rest] -> {
      let new = list.map(rest, fn(q) { #(distance(p, q), p, q) })
      edges_rec(rest, list.append(edges, new))
    }
  }
}

pub fn sizes(uf, points) {
  points
  |> list.fold(#(uf, dict.new()), fn(state, point) {
    let #(uf, sizes) = state
    let #(uf, root) = uf.find(uf, point)
    let assert Ok(size) = dict.get(uf.size, root)
    #(uf, dict.insert(sizes, root, size))
  })
  |> fn(state) { state.1 }
  |> dict.values()
}

pub fn p2() {
  let points = input()
  let edges = edges(points) |> list.sort(compare)
  let mst = kruskal(points, edges)
  let assert Ok(#(_, #(x1, _, _), #(x2, _, _))) = list.first(mst)
  x1 * x2
}

// https://en.wikipedia.org/wiki/Kruskal%27s_algorithm
fn kruskal(points, edges) {
  let n = list.length(edges)
  edges
  |> list.fold(#(uf.new(points), []), fn(state, edge) {
    let #(djs, mst) = state
    case list.length(mst) >= n {
      // all edges are connected
      True -> state
      False -> {
        let #(_, p1, p2) = edge
        let #(djs, are_connected) = uf.connected(djs, p1, p2)
        case are_connected {
          True -> #(djs, mst)
          False -> {
            let djs = uf.union(djs, p1, p2)
            #(djs, [edge, ..mst])
          }
        }
      }
    }
  })
  |> fn(r) { r.1 }
}
