defmodule D11 do
  def p1() do
    stones = get_input("11")
    res = blink(stones, 25, [])
    IO.inspect(length(res))
  end

  defp get_input(day) do
    Helpers.get_lines_strm(day)
    |> Stream.flat_map(&String.split(&1, " ", trim: true))
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end

  defp blink([], n, res) do
    blink(res, n - 1, [])
  end

  defp blink(stones, 0, _) do
    stones
  end

  defp blink([stone | rest], n, res) do
    case stone do
      0 ->
        blink(rest, n, [1 | res])

      stone ->
        str_stone = Integer.to_string(stone)
        len = String.length(str_stone)
        even_digits = Integer.mod(len, 2) == 0

        if even_digits do
          {a, b} = String.split_at(str_stone, div(len, 2))
          blink(rest, n, [String.to_integer(b), String.to_integer(a) | res])
        else
          blink(rest, n, [stone * 2024 | res])
        end
    end
  end

  def p2() do
    stones = get_input("11")
    res = blink_dd(stones, 75)
    IO.inspect(res)
  end

  defp blink_dd(stones, n) do
    stones
    |> Enum.map(fn i -> {i, 1} end)
    |> blink_t(n, %{})
    |> Map.values()
    |> Enum.sum()
  end

  defp blink_t([], n, map) do
    blink_t(Map.to_list(map), n - 1, %{})
  end

  defp blink_t(stones, 0, _) do
    Map.new(stones)
  end

  defp blink_t([{stone, cnt} | rest], n, map) do
    case stone do
      0 ->
        map = Map.update(map, 1, cnt, &inc(&1, cnt))
        blink_t(rest, n, map)

      stone ->
        str_stone = Integer.to_string(stone)
        len = String.length(str_stone)
        even_digits = Integer.mod(len, 2) == 0

        if even_digits do
          {a, b} = String.split_at(str_stone, div(len, 2))
          {a, b} = {String.to_integer(a), String.to_integer(b)}

          map =
            map
            |> Map.update(a, cnt, &inc(&1, cnt))
            |> Map.update(b, cnt, &inc(&1, cnt))

          blink_t(rest, n, map)
        else
          stone = stone * 2024
          map = Map.update(map, stone, cnt, &inc(&1, cnt))
          blink_t(rest, n, map)
        end
    end
  end

  defp inc(v, n), do: v + n
end

D11.p1()
D11.p2()
