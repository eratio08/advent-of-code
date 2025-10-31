module [ListArr, new, put, get, get_opt]

ListArr a : { x : U64, y : U64, data : List a }

new : U64, U64 -> ListArr a
new = |x, y|
    { x, y, data: List.with_capacity(x * y) }

expect
    l = new(10, 10)
    List.len(l.data) == 0 and l.x == 10 and l.y == 10

idx = |x, i, j|
    j * x + i

put : ListArr a, U64, U64, a -> ListArr a
put = |l, i, j, a|
    d = idx(l.x, i, j)
    data = List.set(l.data, d, a)
    { l & data: data }

get : ListArr a, U64, U64 -> Result a [OutOfBounds]
get = |l, i, j|
    d = idx(l.x, i, j)
    List.get(l.data, d)

get_opt : ListArr a, U64, U64 -> [None, Some a]
get_opt = |l, i, j|
    d = idx(l.x, i, j)
    when List.get(l.data, d) is
        Err _ -> None
        Ok x -> Some x

