import d04
import gleam/dict
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn eq_test() {
  let eq =
    d04.eq(
      dict.from_list([#("a", 2), #("b", 2)]),
      dict.from_list([#("a", 2), #("b", 2)]),
    )
  assert eq == True

  let eq =
    d04.eq(
      dict.from_list([#("a", 2), #("b", 2)]),
      dict.from_list([#("a", 3), #("b", 2)]),
    )

  assert eq == False

  let eq =
    d04.eq(
      dict.from_list([#("a", 2), #("b", 2)]),
      dict.from_list([#("a", 2), #("b", 2), #("c", 2)]),
    )

  assert eq == False
}
