import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string
import lib

fn input() {
  lib.words_lines("input/d4")
}

pub fn p1() {
  input()
  |> list.fold(0, fn(s, words) {
    case list.length(words) == set.size(set.from_list(words)) {
      True -> s + 1
      False -> s
    }
  })
}

pub fn p2() {
  input()
  |> list.map(fn(line) { list.map(line, bag) })
  |> list.fold(0, fn(s, words) {
    case is_valid(words) {
      True -> s + 1
      False -> s
    }
  })
}

fn bag(word: String) -> Dict(String, Int) {
  string.to_graphemes(word)
  |> list.fold(dict.from_list([]), fn(s, c) {
    dict.upsert(s, c, fn(o) {
      case o {
        Some(v) -> v + 1
        None -> 1
      }
    })
  })
}

fn is_valid(line) {
  case line {
    [] -> True
    [a, ..rest] ->
      case has_anagram(a, rest) {
        True -> False
        False -> is_valid(rest)
      }
  }
}

fn has_anagram(w, line) {
  case line {
    [] -> False
    [a, ..rest] ->
      case eq(w, a) {
        True -> True
        False -> has_anagram(w, rest)
      }
  }
}

pub fn eq(b1, b2) {
  case dict.size(b1) == dict.size(b2) {
    False -> False
    True ->
      b1
      |> dict.fold(True, fn(s, k, v) {
        case dict.get(b2, k) {
          Ok(w) -> v == w && s
          Error(_) -> False
        }
      })
  }
}
