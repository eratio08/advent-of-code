import d01
import d02
import lib

pub fn main() {
  case lib.get_args() {
    ["1.1"] -> lib.run(d01.p1)
    ["1.2"] -> lib.run(d01.p2)
    ["2.1"] -> lib.run(d02.p1)
    ["2.2"] -> lib.run(d02.p2)
    _ -> panic as "Missing args"
  }
}
