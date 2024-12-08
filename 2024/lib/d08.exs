defmodule D08 do
  def p1() do
    m = Helpers.get_m2("8")
    h = M2.height(m)
    input = parse_input(m, h)
    r = 0..(h - 1)

    antinodes =
      Map.values(input)
      |> Stream.map(&build_combinations(&1, []))
      |> Stream.flat_map(&build_fns(&1, []))
      |> Stream.map(fn {v, fun} -> fun.(v) end)
      |> Stream.filter(&in_range?(&1, r))
      |> Enum.to_list()

    unique = MapSet.new(antinodes)

    IO.inspect(MapSet.size(unique))
  end

  defp parse_input(m, h) do
    Enum.reduce(0..(h - 1), %{}, fn y, map ->
      Enum.reduce(0..(h - 1), map, fn x, map ->
        v = M2.get!(m, x, y)

        case v do
          "." -> map
          v -> Map.update(map, v, [{x, y}], fn pos -> pos ++ [{x, y}] end)
        end
      end)
    end)
  end

  defp build_combinations([], combs), do: combs

  defp build_combinations([a | rest], combs) do
    combs = Enum.reduce(rest, combs, fn b, combs -> combs ++ [{a, b}] end)
    build_combinations(rest, combs)
  end

  defp build_fns([], fns), do: fns

  defp build_fns([{a, b} | rest], fns) do
    build_fns(rest, fns ++ [{a, build_fn(a, b)}, {b, build_fn(b, a)}])
  end

  defp build_fn({ax, ay}, {bx, by}) do
    fn {x, y} -> {x + (ax - bx), y + (ay - by)} end
  end

  defp in_range?({x, y}, r) do
    x in r and y in r
  end

  def p2() do
    m = Helpers.get_m2("8")
    h = M2.height(m)
    input = parse_input(m, h)
    r = 0..(h - 1)
    antennas = Map.values(input)

    antinodes =
      antennas
      |> Stream.map(&build_combinations(&1, []))
      |> Stream.flat_map(&build_fns(&1, []))
      |> Stream.flat_map(fn {p, fun} -> apply_in_range(p, fun, r, []) end)
      |> Enum.to_list()

    unique = MapSet.new(antinodes ++ List.flatten(antennas))

    IO.inspect(MapSet.size(unique))
  end

  defp apply_in_range(p, fun, r, nodes) do
    p_next = fun.(p)

    if in_range?(p_next, r) do
      apply_in_range(p_next, fun, r, nodes ++ [p_next])
    else
      nodes
    end
  end

  # debug by visualizing
  defp place_antinodes(m, antinodes) do
    r = 0..(M2.height(m) - 1)

    Enum.reduce(r, m, fn y, m ->
      Enum.reduce(r, m, fn x, m ->
        case {MapSet.member?(antinodes, {x, y}), M2.get!(m, x, y)} do
          {true, "."} -> M2.put!(m, x, y, "#")
          {true, _} -> M2.put!(m, x, y, "!")
          {false, _} -> m
        end
      end)
    end)
  end
end

D08.p1()
D08.p2()
