defmodule D06 do
  def p1() do
    m = Helpers.get_matrix("6")

    start = find_start(m)
    steps = walk(m, start, :up, [start])
    unique = MapSet.new(steps)
    IO.inspect(MapSet.size(unique))
  end

  defp find_start(m) do
    max = length(m) - 1
    range = 0..max
    [start] = for y <- range, x <- range, at(m, x, y) == "^", do: {x, y}
    start
  end

  defp step({x, y}, dir) do
    case dir do
      :up -> {x, y - 1}
      :left -> {x - 1, y}
      :down -> {x, y + 1}
      :right -> {x + 1, y}
    end
  end

  defp rorate(dir) do
    case dir do
      :up -> :right
      :left -> :up
      :down -> :left
      :right -> :down
    end
  end

  defp walk(m, prev, dir, steps) do
    {x, y} = next = step(prev, dir)
    range = 0..(length(m) - 1)

    if x in range and y in range do
      case at(m, x, y) do
        "#" ->
          walk(m, prev, rorate(dir), steps)

        p when p in [".", "^"] ->
          walk(m, next, dir, [next | steps])
      end
    else
      steps
    end
  end

  defp at(m, x, y), do: Enum.at(m, y) |> Enum.at(x)

  defp set_at(m, v, x, y),
    do: List.update_at(m, y, fn xs -> List.update_at(xs, x, fn _ -> v end) end)

  def p2() do
    m = Helpers.get_matrix("6")
    start = find_start(m)
    steps = walk(m, start, :up, [start]) |> Enum.reverse()
    # all possible block points
    unique = MapSet.new(steps)

    szenarios = unique |> Enum.map(fn {x, y} -> set_at(m, "#", x, y) end)
    loops = szenarios |> Enum.filter(&has_loop(&1, MapSet.new([{start, :up}]), start, :up))

    # to remove the one that is invalid due to guards start position
    IO.inspect(length(loops) - 1)
  end

  defp has_loop(m, turns, prev, dir) do
    {x, y} = next = step(prev, dir)
    range = 0..(length(m) - 1)

    if x in range and y in range do
      case at(m, x, y) do
        "#" ->
          turn = {next, rorate(dir)}

          if MapSet.member?(turns, turn) do
            true
          else
            has_loop(m, MapSet.put(turns, turn), prev, rorate(dir))
          end

        p when p in [".", "^"] ->
          has_loop(m, turns, next, dir)
      end
    else
      false
    end
  end
end

D06.p1()
D06.p2()
