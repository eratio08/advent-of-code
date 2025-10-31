module [part_1, part_2]

import "input/d1" as input_raw : Str
import unicode.Grapheme

input =
    input_raw
    |> Grapheme.split
    |> Result.with_default([])
    |> List.drop_if(|c| c == "\n")
    |> List.map_try(Str.to_i64)
    |> Result.with_default([])

part_1 = |{}|
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

    (h, t) =
        when input is
            [a, .. as rest] -> (a, rest)
            _ -> crash "No"
    rec(t, h, 0)

part_2 = |{}|
    ns = input
    len = List.len(ns)
    window = (len // 2)

    rec = |i, sum|
        if i >= len then
            sum
        else
            a = List.get(ns, i) ?? -1
            b = List.get(ns, ((i + window) % len)) ?? -1
            if a == b then
                rec(i + 1, sum + a)
            else
                rec(i + 1, sum)

    rec(0, 0)
