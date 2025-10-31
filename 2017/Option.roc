module [Option, none, some, value, get, bind, join, map, fold]

Option a : [None, Some a]

none : Option _
none = None

some : a -> Option a
some = |a| Some a

value : Option a, a -> a
value = |o, default|
    when o is
        None -> default
        Some a -> a

get : Option a -> a
get = |o|
    when o is
        None -> crash("Option has no value")
        Some a -> a

bind : Option a, (a -> Option b) -> Option b
bind = |o, fn|
    when o is
        None -> None
        Some a -> fn(a)

join : Option (Option a) -> Option a
join = |o|
    bind(o, |i| i)

map : Option a, (a -> b) -> Option b
map = |o, fn|
    bind(o, |i| Some(fn(i)))

fold : Option b, { none : a, some : b -> a } -> a
fold = |o, args|
    when o is
        None -> args.none
        Some b -> args.some(b)
