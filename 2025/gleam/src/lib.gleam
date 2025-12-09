import gleam/bit_array
import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import grid.{type Grid}

@external(erlang, "file", "read_file")
fn erl_read_file(path: String) -> Result(BitArray, reason)

pub fn read_file(path) {
  let bits = value_msg(erl_read_file(path), "failed to read file " <> path)
  value_msg(bit_array.to_string(bits), "failed to convert file bytes to string")
}

pub fn chars(path) {
  let content = read_file(path)
  let lines = string.split(content, on: "")
  let len = list.length(lines)
  list.take(lines, len - 1)
}

pub fn line_chars(path) {
  lines(path)
  |> list.map(fn(line) { string.split(line, on: "") })
}

pub fn ints(path) {
  let chars = chars(path)
  value_msg(list.try_map(chars, int.parse), "failed to parse chars as ints")
}

pub fn line_ints(path) {
  line_chars(path)
  |> list.try_map(fn(chars) { list.try_map(chars, int.parse) })
  |> value_msg("failed to parse line chars as ints")
}

pub fn lines(path) {
  let content = read_file(path)
  let lines = string.split(content, on: "\n")
  let len = list.length(lines)
  list.take(lines, len - 1)
}

pub fn words_lines(path) {
  lines(path) |> list.map(fn(line) { string.split(line, on: " ") })
}

pub fn words_lines_trimmed(path) {
  lines(path)
  |> list.map(fn(line) {
    string.split(line, on: " ")
    |> list.map(string.trim)
    |> list.filter(fn(w) { !string.is_empty(w) })
  })
}

pub fn read_grid(path) -> Grid(String) {
  let lines = line_chars(path)

  lines
  |> list.index_map(fn(row, j) {
    row |> list.index_map(fn(val, i) { #(#(i, j), val) })
  })
  |> list.flatten()
  |> dict.from_list()
  |> fn(g) {
    let n = list.length(value(list.first(lines)))
    let m = list.length(lines)
    grid.Grid(g, n, m)
  }
}

@external(erlang, "init", "get_plain_arguments")
fn get_plain_arguments() -> List(List(Int))

@external(erlang, "erlang", "list_to_binary")
fn list_to_binary(charlist: List(Int)) -> BitArray

pub fn get_args() {
  get_plain_arguments()
  |> list.map(fn(charlist) {
    charlist
    |> list_to_binary
    |> bit_array.to_string
    |> result.unwrap(or: "")
  })
}

@external(erlang, "timer", "tc")
pub fn timer(f: fn() -> a) -> #(Int, a)

pub fn run(f: fn() -> Int) {
  let #(took_micro, n) = timer(f)

  let took_s = int.to_float(took_micro) /. 1000.0 /. 1000.0
  io.println("\n🏁 Took " <> float.to_string(took_s) <> "s")
  io.println("➡️ " <> int.to_string(n))

  Nil
}

pub fn value_msg(r: Result(a, b), msg: String) -> a {
  case r {
    Ok(v) -> v
    Error(e) -> {
      echo e
      panic as msg
    }
  }
}

pub fn value(r: Result(a, b)) -> a {
  value_msg(r, "result was Error")
}

pub fn value_o(o: option.Option(a)) -> a {
  case o {
    option.Some(v) -> v
    option.None -> panic as "option was None"
  }
}

pub fn int_list_max(l: List(Int)) -> Int {
  l
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.first()
  |> result.unwrap(0)
}

pub fn int_list_min(l: List(Int)) -> Int {
  l |> list.sort(int.compare) |> list.first() |> result.unwrap(0)
}
