defmodule D20 do
  def p1 do
    path = parse_input("20") |> bfs()
    path_tup = Enum.reduce(path, {}, fn p, acc -> Tuple.append(acc, p) end)
    count_cheats(path_tup, 2) |> IO.inspect()
  end

  defp parse_input(day) do
    m2 = Helpers.get_m2(day)

    map =
      m2
      |> M2.as_list_pos()
      |> Enum.group_by(fn {_pos, value} -> value end, fn {pos, _value} -> pos end)

    start = hd(Map.get(map, "S"))
    goal = hd(Map.get(map, "E"))
    walls = MapSet.new(Map.get(map, "#"))
    range = 0..(M2.height(m2) - 1)

    {start, goal, walls, range}
  end

  @directions [
    # up
    {0, -1},
    # right
    {1, 0},
    # down
    {0, 1},
    # left
    {-1, 0}
  ]

  def bfs({start, goal, walls, range}) do
    queue = :queue.in({start, [start]}, :queue.new())
    visited = MapSet.new([start])

    bfs_recursive(queue, visited, walls, range, goal)
  end

  defp bfs_recursive(queue, visited, walls, range, goal) do
    if :queue.is_empty(queue) do
      :no_path
    end

    {{:value, {current, path}}, queue} = :queue.out(queue)

    if current == goal do
      Enum.reverse(path)
    else
      {new_queue, new_visited} =
        get_next(current, walls, range)
        |> Stream.reject(&MapSet.member?(visited, &1))
        |> Enum.reduce({queue, visited}, fn next, {q, v} ->
          {:queue.in({next, [next | path]}, q), MapSet.put(v, next)}
        end)

      bfs_recursive(new_queue, new_visited, walls, range, goal)
    end
  end

  defp get_next({x, y}, walls, range) do
    @directions
    |> Stream.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Stream.filter(fn {x, y} = next ->
      in_range = x in range and y in range
      can_move = not MapSet.member?(walls, next)
      in_range and can_move
    end)
  end

  # Idea: Given the path from S to E and two positions A and B on that path.
  # Check if going from A directly to B and skipping all positions between
  # A and B improves the over all time. The distance between A and B must not
  # be grater than the duration it is allowed to cheat.
  defp count_cheats(path, duration) do
    Enum.reduce(0..(tuple_size(path) - 2), 0, fn i, sum ->
      Enum.reduce((i + 1)..(tuple_size(path) - 1), sum, fn j, sum ->
        {ax, ay} = elem(path, i)
        {bx, by} = elem(path, j)
        # taxi-distance
        dx = abs(ax - bx)
        dy = abs(ay - by)
        dist = dx + dy

        # only consider distances that can be done in given duration
        can_cheat = dist <= duration
        ab_dist = j - i
        time_safed = ab_dist - dist

        if can_cheat && time_safed >= 100 do
          sum + 1
        else
          sum
        end
      end)
    end)
  end

  def p2 do
    path = parse_input("20") |> bfs()
    path_tup = Enum.reduce(path, {}, fn p, acc -> Tuple.append(acc, p) end)
    count_cheats(path_tup, 20) |> IO.inspect()
  end
end

D20.p1()
D20.p2()
