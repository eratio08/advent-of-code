import gleam/bit_array
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

@external(erlang, "file", "read_file")
fn erl_read_file(path: String) -> Result(BitArray, reason)

pub fn read_file(path) {
  case erl_read_file(path) {
    Ok(bits) -> bit_array.to_string(bits)
    Error(_reason) -> Error(Nil)
  }
}

pub fn chars(path) {
  use content <- result.try(read_file(path))
  let lines = string.split(content, on: "")
  let len = list.length(lines)
  // omit trailing element
  Ok(list.take(lines, len - 1))
}

pub fn ints(path) {
  use chars <- result.try(chars(path))
  list.try_map(chars, int.parse)
}

pub fn lines(path) {
  use content <- result.try(read_file(path))
  let lines = string.split(content, on: "\n")
  let len = list.length(lines)
  // omit trailing element
  Ok(list.take(lines, len - 1))
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

pub fn run(f: fn() -> Result(Int, a)) {
  let #(took_micro, n) = timer(f)

  let took_ms = int.to_float(took_micro) /. 1000.0 /. 1000.0
  io.println("\n🏁 Took " <> float.to_string(took_ms) <> "ms")

  case n {
    Ok(n) -> io.println("➡️ " <> int.to_string(n))
    Error(_) -> io.println_error("failed")
  }

  Nil
}
