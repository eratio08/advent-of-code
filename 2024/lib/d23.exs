defmodule D23 do
  def p1 do
    graph = parse_input("23")
    ts = Map.keys(graph) |> Enum.filter(fn it -> String.starts_with?(it, "t") end)
    interc = interconeccted(graph)

    with_t =
      MapSet.filter(interc, fn ms ->
        Enum.any?(ts, fn t -> MapSet.member?(ms, t) end)
      end)

    IO.inspect(MapSet.size(with_t))
  end

  defp parse_input(day) do
    input = Helpers.get_lines_strm(day) |> Stream.map(fn l -> String.split(l, "-") end)

    adjacency =
      Enum.reduce(input, %{}, fn [a, b], map ->
        map
        |> Map.update(a, MapSet.new([b]), fn bs -> MapSet.put(bs, b) end)
        |> Map.update(b, MapSet.new([a]), fn as -> MapSet.put(as, a) end)
      end)

    adjacency
  end

  defp interconeccted(adj) do
    Enum.reduce(Map.to_list(adj), MapSet.new(), fn {a, ac}, acc ->
      Enum.reduce(ac, acc, fn b, acc ->
        bs = Map.get(adj, b, MapSet.new())

        Enum.reduce(bs, acc, fn c, acc ->
          cs = Map.get(adj, c, MapSet.new())

          case MapSet.member?(cs, a) do
            true -> MapSet.put(acc, MapSet.new([a, b, c]))
            false -> acc
          end
        end)
      end)
    end)
  end

  def maximum_clique(graph) do
    bron_kerbosch(MapSet.new(), MapSet.new(Map.keys(graph)), MapSet.new(), graph)
    |> Enum.max(fn a, b -> MapSet.size(a) >= MapSet.size(b) end)
  end

  # https://en.wikipedia.org/wiki/Bron%E2%80%93Kerbosch_algorithm#With_pivoting
  defp bron_kerbosch(r, p, x, graph) do
    if MapSet.size(p) == 0 and MapSet.size(x) == 0 do
      [r]
    else
      pivot = Enum.random(MapSet.union(p, x))
      pivot_neighbors = graph[pivot] || []
      # do not consider the pivot neighbors, by exclusion from p
      p_without_pivot_neibours = MapSet.difference(p, pivot_neighbors)

      Enum.reduce(p_without_pivot_neibours, [], fn node, acc ->
        bron_kerbosch(
          MapSet.put(r, node),
          MapSet.intersection(p, graph[node]),
          MapSet.intersection(x, graph[node]),
          graph
        ) ++ acc
      end)
    end
  end

  def p2 do
    graph = parse_input("23t")

    maximum_clique(graph)
    |> MapSet.to_list()
    |> Enum.sort()
    |> Enum.join(",")
    |> IO.inspect()
  end
end

D23.p1()
D23.p2()
