import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import lib

type Graph =
  dict.Dict(String, List(String))

fn input() -> Graph {
  lib.lines("input/d11")
  |> list.map(fn(line) {
    let assert [name, devices] = line |> string.split(":")
    let output = devices |> string.split(" ") |> list.filter(fn(s) { s != "" })
    #(name, output)
  })
  |> dict.from_list()
}

pub fn p1() {
  input() |> bfs() |> dict.get("out") |> result.unwrap(0)
}

fn bfs(graph) {
  let visited = set.from_list(["you"])
  let queue = ["you"]
  let pathes = dict.from_list([#("you", 1)])
  bfs_rec(graph, #(visited, queue, pathes))
}

type State =
  #(set.Set(String), List(String), dict.Dict(String, Int))

fn bfs_rec(graph, state: State) -> Dict(String, Int) {
  let #(visited, queue, pathes) = state
  case queue {
    [] -> pathes
    [current, ..rest] -> {
      case dict.get(graph, current) {
        Ok(devices) -> {
          let state =
            devices
            |> list.fold(#(visited, rest, pathes), fn(state, device) {
              let #(visited, queue, pathes) = state
              let cur_cnt = dict.get(pathes, current) |> result.unwrap(0)
              let device_cnt = dict.get(pathes, device) |> result.unwrap(0)
              let pathes = dict.insert(pathes, device, cur_cnt + device_cnt)

              case set.contains(visited, device) {
                True -> #(visited, queue, pathes)
                False -> {
                  let visited = set.insert(visited, device)
                  let queue = list.append(queue, [device])
                  #(visited, queue, pathes)
                }
              }
            })
          bfs_rec(graph, state)
        }
        _ -> bfs_rec(graph, #(visited, rest, pathes))
      }
    }
  }
}

// not my idea, https://github.com/timvisee/advent-of-code-2025/blob/master/day11b/src/main.rs
pub fn p2() {
  let fwd = input()
  let bwd = backward_graph(fwd)

  let path1 =
    paths(fwd, bwd, "dac", "fft")
    * paths(fwd, bwd, "svr", "dac")
    * paths(fwd, bwd, "fft", "out")

  let path2 =
    paths(fwd, bwd, "fft", "dac")
    * paths(fwd, bwd, "svr", "fft")
    * paths(fwd, bwd, "dac", "out")

  path1 + path2
}

fn backward_graph(fwd: Graph) -> Dict(String, Set(String)) {
  fwd
  |> dict.fold(dict.new(), fn(bwd, node, neighbors) {
    neighbors
    |> list.fold(bwd, fn(bwd, neighbor) {
      let incoming =
        dict.get(bwd, neighbor) |> result.unwrap(set.new()) |> set.insert(node)
      dict.insert(bwd, neighbor, incoming)
    })
  })
}

// https://www.geeksforgeeks.org/dsa/topological-sorting-indegree-based-solution/
fn paths(
  fwd: Graph,
  bwd: Dict(String, Set(String)),
  from: String,
  to: String,
) -> Int {
  let pathes = dict.from_list([#(from, 1)])
  // nodes which are not in the bwd are not pointed to in the fwd so they have an indegree of 0
  let queue =
    dict.keys(fwd) |> list.filter(fn(node) { !dict.has_key(bwd, node) })
  let pathes = walk_topology(fwd, bwd, pathes, queue)
  dict.get(pathes, to) |> result.unwrap(0)
}

fn walk_topology(
  fwd: Graph,
  bwd: Dict(String, Set(String)),
  pathes: Dict(String, Int),
  queue: List(String),
) -> Dict(String, Int) {
  case queue {
    [] -> pathes
    [node, ..rest] -> {
      let node_pathes = dict.get(pathes, node) |> result.unwrap(0)

      let #(pathes, bwd, queue) =
        dict.get(fwd, node)
        |> result.unwrap([])
        |> list.fold(#(pathes, bwd, rest), fn(state, neighbor) {
          let #(pathes, bwd, queue) = state

          let neighbor_pathes = dict.get(pathes, neighbor) |> result.unwrap(0)
          let neighbor_pathes = neighbor_pathes + node_pathes
          let pathes = dict.insert(pathes, neighbor, neighbor_pathes)

          let indegree = dict.get(bwd, neighbor) |> result.unwrap(set.new())
          let indegree = set.delete(indegree, node)
          let bwd = dict.insert(bwd, neighbor, indegree)

          case set.is_empty(indegree) {
            // queue neighbor node with indegree 0
            True -> #(pathes, bwd, list.append(queue, [neighbor]))

            False -> #(pathes, bwd, queue)
          }
        })

      walk_topology(fwd, bwd, pathes, queue)
    }
  }
}
