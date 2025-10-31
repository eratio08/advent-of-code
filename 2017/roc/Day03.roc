module [part_1, part_2]

# import ListArr

input = 347991

nr_on_ring = |ring|
    rec = |x, n|
        if
            x == (ring + 1)
        then
            n
        else
            rec(x + 1, n + (x * 8))
    rec(0, 1)

ring_of = |n|
    rec = |x|
        if
            nr_on_ring(x) >= n
        then
            x
        else
            rec(x + 1)
    rec(0)

expect (dbg ring_of(12)) == 2

pos_on_ring = |n, ring|
    n - (nr_on_ring(ring - 1))

expect (dbg pos_on_ring(12, 2)) == 3

pos_on_side = |p, r|
    (p - 1) % (r * 2)

expect (dbg pos_on_side(3, 2)) == 2

dist_from_mid = |p, r|
    Num.abs(p - (r - 1))

expect (dbg dist_from_mid(2, 2)) == 1

part_1 = |{}|
    n = input
    ring = ring_of(n)
    pos = pos_on_ring(n, ring)
    side = pos_on_side(pos, ring)
    dist = dist_from_mid(side, ring)
    ring + dist

# directions = [
#     (1, 0), # right
#     (0, 1), # up
#     (-1, 0), # left
#     (0, -1), # down
#     # diagonal
#     (1, 1), # up right
#     (-1, 1), # up left
#     (-1, -1), # down left
#     (-1, 1), # down right
# ]

part_2 = |{}|
    # arr = ListArr.new(1024, 1024)
    0
