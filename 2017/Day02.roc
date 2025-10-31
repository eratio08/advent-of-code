module [part_1, part_2]

import "input/day02" as input_raw : Str

numbers = |input|
    Str.split_on(input, "\n")
    |> List.map_try(
        |row|
            row
            |> Str.split_on("\t")
            |> List.drop_if(|n| n == "")
            |> List.map_try(Str.to_u64),
    )
    |> Result.map_ok(
        |rows|
            List.drop_if(rows, |row| row == []),
    )

ns = numbers(input_raw)

part_1 = |{}|
    r = List.walk(
        ns?,
        0,
        |cs, row|
            max = List.max(row) ?? 0
            min = List.min(row) ?? 0
            cs + Num.abs_diff(max, min),
    )
    Ok(r)

even_div = |a, row|
    when row is
        [] -> None
        [b, .. as rest] ->
            (x, y) = if a >= b then (a, b) else (b, a)
            if
                Num.rem(x, y) == 0
            then
                Some(Num.div_ceil(x, y))
            else
                even_div(a, rest)

find_even_div = |row|
    when row is
        [] -> None
        [h, .. as tail] ->
            when even_div(h, tail) is
                None -> find_even_div(tail)
                x -> x

part_2 = |{}|
    ns_raw = ns ?? [[]]
    List.walk_try(
        ns_raw,
        # x,
        0,
        |checksum, row|
            when find_even_div(row) is
                None -> Err("No even div in ${Inspect.to_str(row)}")
                Some g -> Ok(checksum + g),
    )

