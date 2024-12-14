defmodule D14 do
  def p1 do
    n = 100
    {lx, ly} = limits = {101, 103}
    mids = {div(lx, 2), div(ly, 2)}

    parse_input("14")
    |> Stream.map(&move(&1, n, limits))
    |> Stream.filter(fn {p, _} -> not_mid?(p, mids) end)
    |> Enum.frequencies_by(fn {p, _} -> get_quadrent(p, mids) end)
    |> Map.to_list()
    |> Stream.filter(fn {k, _} -> k != -1 end)
    |> Stream.map(fn {_, v} -> v end)
    |> Enum.product()
    |> IO.inspect()
  end

  defp get_quadrent({x, y}, {mx, my}) do
    cond do
      x < mx and y < my -> 0
      x > mx and y < my -> 1
      x > mx and y > my -> 2
      x < mx and y > my -> 3
    end
  end

  defp not_mid?({x, y}, {mx, my}) do
    x != mx and y != my
  end

  defp parse_input(day) do
    Helpers.get_lines_strm(day)
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    [p, v] = String.split(line, " ", trim: true)
    {parse_tupel(p), parse_tupel(v)}
  end

  defp parse_tupel(v_str) do
    [_, v] = String.split(v_str, "=", trim: true)
    [x, y] = String.split(v, ",", trim: true)
    {String.to_integer(x), String.to_integer(y)}
  end

  defp move({{px, py}, {vx, vy} = v}, n, {lx, ly}) do
    x = Integer.mod(px + vx * n, lx)
    y = Integer.mod(py + vy * n, ly)
    {{x, y}, v}
  end

  def p2 do
    limits = {101, 103}

    ps = parse_input("14")
    {ps, n} = run(ps, 1, limits, 10_000_000)

    draw(ps, limits)
    IO.inspect(n)
  end

  defp new_map({lx, ly}) do
    List.foldl(0..(ly - 1) |> Range.to_list(), {}, fn _, row ->
      Tuple.append(
        row,
        List.foldl(0..(lx - 1) |> Range.to_list(), {}, fn _, line ->
          Tuple.append(line, ".")
        end)
      )
    end)
  end

  defp has_horizontal_line?(pp) do
    line =
      pp
      |> Enum.reduce(%{}, fn {{_, y} = p, _}, map ->
        Map.update(map, y, [p], fn pp -> [p | pp] end)
      end)
      |> Map.values()
      |> Enum.filter(fn ps -> length(ps) > 20 end)
      |> Enum.map(fn ps -> Enum.map(ps, fn {x, _} -> x end) end)
      |> Enum.filter(fn ps ->
        ps = Enum.sort(ps)

        {is_line, _} =
          List.foldr(ps, {true, -1}, fn
            x, {row, -1} ->
              {row, x}

            _, {false, _} ->
              {false, -1}

            x, {row, prev} ->
              {row and abs(x - prev) <= 1, x}
          end)

        is_line
      end)

    length(line) > 0
  end

  defp run(ps, n, limits, max) do
    if n == max do
      {ps, n}
    else
      ps = Enum.map(ps, &move(&1, 1, limits))

      if has_horizontal_line?(ps) do
        {ps, n}
      else
        run(ps, n + 1, limits, max)
      end
    end
  end

  defp draw(ps, limits) do
    map = new_map(limits)
    map = Enum.reduce(ps, map, fn {{x, y}, _}, map -> M2.put!(map, x, y, "#") end)
    draw_map(map)
  end

  defp draw_map(map) do
    ly = tuple_size(map)
    lx = tuple_size(elem(map, 0))

    s =
      Enum.reduce(0..(ly - 1), "", fn y, s ->
        row =
          Enum.reduce(0..(lx - 1), s, fn x, s ->
            s <> M2.get!(map, x, y)
          end)

        row <> "\n"
      end)

    IO.puts(s)
  end
end

D14.p1()
D14.p2()
