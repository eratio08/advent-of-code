module [chars, lines, lcm, gcd]

import unicode.Grapheme

chars = |str|
    str
    |> Grapheme.split
    |> Result.map_ok(|l| List.drop_if(l, |c| c == "\n"))

lines = |str|
    str
    |> Str.split_on("\n")

gcd = |a, b|
    when b is
        0 -> a
        _ -> gcd(b, Num.rem(a, b))

lcm = |a, b|
    Num.div_ceil(
        Num.abs(a * b),
        gcd(a, b),
    )
