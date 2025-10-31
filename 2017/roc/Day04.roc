module [part_1, part_2]

import "input/d4" as input_raw : Str
import Lib

input =
    Lib.lines(input_raw)
    |> List.map(|line| Str.split_on(line, " "))

part_1 = |{}|
    input
    |> List.walk(
        0,
        |c, words|
            set = List.walk(words, Set.empty({}), |s, w| Set.insert(s, w))
            n = List.len(words)
            m = Set.len(set)
            if m == n then c + 1 else c,
    )

part_2 = |{}|
    input
    |> List.walk(
        0,
        |c, words|
            when has_anagram(words) is
                Bool.true -> c
                Bool.false -> c + 1
                _ -> crash "",
    )

has_anagram : List Str -> Bool
has_anagram = |words|
    char_maps = List.map(words, build_bag)
    rec = |cs|
        when cs is
            [] -> Bool.false
            [h, .. as rest] -> List.walk(rest, Bool.true, |s, c| s and is_anagram(h, c))
    rec(char_maps)

build_bag : Str -> Dict Str U8
build_bag = |w|
    Lib.chars_must(w)
    |> List.walk(
        Dict.empty({}),
        |d, char|
            Dict.update(
                d,
                char,
                |r|
                    when r is
                        Ok(n) -> Ok(n + 1)
                        _ -> Ok(1),
            ),
    )

# Word : Dict Str U32
#
# # bag_equal = |b1, b2|
# #   rec = |n|
# #     when n is
# #     [] -> Bool.false
# #     [h, .. as rest] ->
# #       (k, v) = h
# #       when Dict.get(b2, k)
# #         Ok(m) -> if m ==

is_anagram = |a, b|
    if
        Dict.len(a) != Dict.len(b)
    then
        Bool.false
    else
        Dict.walk(
            a,
            Bool.true,
            |s, k, v_a|
                when Dict.get(b, k) is
                    Ok(v_b) -> s and v_a == v_b
                    Err _ -> Bool.false,
        )

expect
    is_anagram(build_bag("ab"), build_bag("ba"))

expect
    (is_anagram(build_bag("ab"), build_bag("baa"))) == Bool.false
