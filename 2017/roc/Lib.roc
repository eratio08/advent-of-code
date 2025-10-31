module [chars, ascii_chars, chars_must, lines, lcm, gcd]

import unicode.Grapheme

chars = |str|
    str
    |> Grapheme.split
    |> Result.map_ok(|l| List.drop_if(l, |c| c == "\n"))

chars_must = |str|
    when chars(str) is
        Ok(cs) -> cs
        Err(_) -> crash "chars where not Ok"

ascii_chars = |str|
    str |> Str.to_utf8() |> List.map(|u| Str.from_utf8_lossy([u]))

lines = |str|
    str
    |> Str.split_on("\n")
    |> List.drop_last(1)

gcd = |a, b|
    when b is
        0 -> a
        _ -> gcd(b, Num.rem(a, b))

lcm = |a, b|
    Num.div_ceil(
        Num.abs(a * b),
        gcd(a, b),
    )
