import d01
import d02
import d03
import d04
import d05
import d06
import d07
import d08
import d09
import lib

pub fn main() {
  case lib.get_args() {
    ["1.1"] -> lib.run(d01.p1)
    ["1.2"] -> lib.run(d01.p2)
    ["2.1"] -> lib.run(d02.p1)
    ["2.2"] -> lib.run(d02.p2)
    ["3.1"] -> lib.run(d03.p1)
    ["3.2"] -> lib.run(d03.p2)
    ["4.1"] -> lib.run(d04.p1)
    ["4.2"] -> lib.run(d04.p2)
    ["5.1"] -> lib.run(d05.p1)
    ["5.2"] -> lib.run(d05.p2)
    ["6.1"] -> lib.run(d06.p1)
    ["6.2"] -> lib.run(d06.p2)
    ["7.1"] -> lib.run(d07.p1)
    ["7.2"] -> lib.run(d07.p2)
    ["8.1"] -> lib.run(d08.p1)
    ["8.2"] -> lib.run(d08.p2)
    ["9.1"] -> lib.run(d09.p1)
    ["9.2"] -> lib.run(d09.p2)
    _ -> panic as "Missing args"
  }
}
