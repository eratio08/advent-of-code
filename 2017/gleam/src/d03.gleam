import lib

fn input() {
  case lib.ints("input/d3") {
    [] -> panic as "input was empty"
    [n, ..] -> n
  }
}

pub fn p1() {
  input()
  0
}

pub fn p2() {
  0
}
