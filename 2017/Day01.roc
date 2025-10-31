module [part_1, part_2]

import "input/day01" as input_p1_raw : Str
import unicode.Grapheme

input_p1 =
    input_p1_raw
    |> Grapheme.split
    |> Result.with_default([])
    |> List.drop_if(|c| c == "\n")
    |> List.map_try(Str.to_i64)
    |> Result.with_default([])

part_1 =
    rec = |ns, cur, sum|
        when ns is
            [a, .. as rest] ->
                if a == cur then
                    rec(rest, a, (sum + a))
                else
                    rec(rest, a, sum)

            [] ->
                if cur == h then
                    (sum + cur)
                else
                    sum

    input = input_p1
    (h, t) =
        when input is
            [a, .. as rest] -> (a, rest)
            _ -> crash "No"
    rec(t, h, 0)

part_2 = 0
