defmodule D10 do
  def p1() do
    {map, trailheads, nines, range} = prep("10")

    paths = find_paths(trailheads, nines, map, range)
    IO.inspect(length(paths))
  end

  defp prep(day) do
    map = Helpers.get_m2(day) |> M2.map(&String.to_integer/1)

    trailheads =
      M2.as_list_pos(map)
      |> Stream.filter(fn
        {_, 0} -> true
        {_, _} -> false
      end)
      |> Enum.map(fn {p, _} -> p end)

    nines =
      M2.as_list_pos(map)
      |> Stream.filter(fn
        {_, 9} -> true
        {_, _} -> false
      end)
      |> Enum.map(fn {p, _} -> p end)

    range = 0..(M2.height(map) - 1)

    {map, trailheads, nines, range}
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

  defp next({x, y}, map, range) do
    w = M2.get!(map, x, y)

    @directions
    |> List.foldl([], fn {dx, dy}, acc ->
      {x, y} = pos = {x + dx, y + dy}

      if !in_range(pos, range) do
        acc
      else
        v = M2.get!(map, x, y)
        n = w + 1

        case v do
          ^n -> [pos | acc]
          _ -> acc
        end
      end
    end)
  end

  defp in_range({x, y}, range) do
    x in range and y in range
  end

  defp find_paths(trailheads, nines, map, range) do
    List.foldl(trailheads, [], fn trailhead, acc ->
      List.foldl(nines, acc, fn nine, acc ->
        path = find_path(trailhead, nine, map, range, [])

        case path do
          [] -> acc
          _ -> [{trailhead, nine, path} | acc]
        end
      end)
    end)
  end

  defp find_path(cur, nine, map, range, path) do
    path = [cur | path]

    if cur == nine do
      {path}
    else
      next(cur, map, range)
      |> Enum.map(fn cur -> find_path(cur, nine, map, range, path) end)
      |> List.flatten()
    end
  end

  def p2() do
    {map, trailheads, nines, range} = prep("10")

    paths = find_ratings(trailheads, nines, map, range)
    IO.inspect(paths |> Enum.sum())
  end

  defp find_ratings(trailheads, nines, map, range) do
    List.foldl(trailheads, [], fn trailhead, acc ->
      List.foldl(nines, acc, fn nine, acc ->
        path = find_path(trailhead, nine, map, range, [])

        case path do
          [] -> acc
          _ -> [length(path) | acc]
        end
      end)
    end)
  end
end

D10.p1()
D10.p2()
