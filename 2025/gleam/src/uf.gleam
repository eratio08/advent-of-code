import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/order
import gleam/result

// https://en.wikipedia.org/wiki/Disjoint-set_data_structure
// If two element are in the same tree they are in the same disjoint set.
// The root of a tree is the representative of the set.
// The representative has it self as a parent.
// With path compression and tree balancing https://www.geeksforgeeks.org/dsa/introduction-to-disjoint-set-data-structure-or-union-find-algorithm
pub type UnionFind(a) {
  UnionFind(parent: Dict(a, a), rank: Dict(a, Int), size: Dict(a, Int))
}

pub fn new(aa: List(a)) -> UnionFind(a) {
  let parent = list.fold(aa, dict.new(), fn(d, p) { dict.insert(d, p, p) })
  let rank = list.fold(aa, dict.new(), fn(d, p) { dict.insert(d, p, 0) })
  let size = list.fold(aa, dict.new(), fn(d, p) { dict.insert(d, p, 1) })

  UnionFind(parent: parent, rank: rank, size: size)
}

// Finds the representative of the set of the given element.
// Performs path compression to return a union find that has the representative as it's direct root.
pub fn find(uf: UnionFind(a), a: a) -> #(UnionFind(a), a) {
  case dict.get(uf.parent, a) {
    Error(_) -> #(uf, a)
    Ok(parent) ->
      case parent == a {
        True -> #(uf, a)
        False -> {
          let #(parent_uf, root) = find(uf, parent)
          // path compression
          let parent = dict.insert(parent_uf.parent, a, root)
          #(UnionFind(..parent_uf, parent: parent), root)
        }
      }
  }
}

// Combine two sets into one.
pub fn union(uf: UnionFind(a), a1: a, a2: a) -> UnionFind(a) {
  let #(uf, r1) = find(uf, a1)
  let #(uf, r2) = find(uf, a2)

  case r1 == r2 {
    True -> uf
    False -> {
      let rank1 = dict.get(uf.rank, r1) |> result.unwrap(0)
      let rank2 = dict.get(uf.rank, r2) |> result.unwrap(0)
      let size1 = dict.get(uf.size, r1) |> result.unwrap(1)
      let size2 = dict.get(uf.size, r2) |> result.unwrap(1)

      // rank is used to balance the tree
      case int.compare(rank1, rank2) {
        order.Lt -> {
          let parent = dict.insert(uf.parent, r1, r2)
          let size = dict.insert(uf.size, r2, size1 + size2)
          UnionFind(..uf, parent: parent, size: size)
        }
        order.Gt -> {
          let parent = dict.insert(uf.parent, r2, r1)
          let size = dict.insert(uf.size, r1, size1 + size2)
          UnionFind(..uf, parent: parent, size: size)
        }
        order.Eq -> {
          let parent = dict.insert(uf.parent, r1, r2)
          let rank = dict.insert(uf.rank, r2, rank2 + 1)
          let size = dict.insert(uf.size, r2, size1 + size2)
          UnionFind(parent: parent, rank: rank, size: size)
        }
      }
    }
  }
}

// If two elements are in the same set.
// Uses path compression.
pub fn connected(uf: UnionFind(a), a1: a, a2: a) -> #(UnionFind(a), Bool) {
  let #(uf, root1) = find(uf, a1)
  let #(uf, root2) = find(uf, a2)
  #(uf, root1 == root2)
}
