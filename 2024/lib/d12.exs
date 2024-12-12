defmodule D12 do
  @directions [
    # up
    {0, -1},
    # right
    {1, 0},
    # down
    {0, 1},
    #  left
    {-1, 0}
  ]

  def p1 do
    {guarden, range, by_label} = get_input("12")

    Enum.flat_map(Map.to_list(by_label), fn {label, positions} ->
      find_clusters(label, positions, [], {guarden, range})
      |> Enum.map(&price_of_cluster(label, &1, {guarden, range}))
    end)
    |> Enum.sum()
    |> IO.inspect()
  end

  defp get_input(day) do
    guarden = Helpers.get_m2(day)
    range = 0..(M2.height(guarden) - 1)

    by_label =
      guarden
      |> M2.reduce_pos(%{}, fn pos, label, map ->
        Map.update(map, label, [pos], fn ps -> [pos | ps] end)
      end)

    {guarden, range, by_label}
  end

  defp price_of_cluster(label, cluster, input) do
    positions = MapSet.to_list(cluster)

    perimeter =
      positions
      |> Stream.map(fn pos -> count_primeter(label, pos, input) end)
      |> Enum.sum()

    area = length(positions)

    perimeter * area
  end

  defp find_clusters(_, [], clusters, _) do
    clusters
  end

  defp find_clusters(label, [pos | rest], clusters, input) do
    case find_cluster(pos, label, MapSet.new(), input) do
      [] ->
        find_clusters(label, rest, clusters, input)

      cluster ->
        clusters = [cluster | clusters]
        cluster_pos = MapSet.to_list(cluster)
        rest = rest -- cluster_pos
        find_clusters(label, rest, clusters, input)
    end
  end

  defp find_cluster(pos, label, cluster, input) do
    cluster = MapSet.put(cluster, pos)

    case next(pos, label, cluster, input) do
      [] ->
        cluster

      next ->
        List.foldr(next, cluster, fn pos, cluster -> find_cluster(pos, label, cluster, input) end)
    end
  end

  defp next(pos, label, cluster, {guarden, range}) do
    @directions
    |> Stream.map(&go_direction(pos, &1))
    |> Enum.filter(fn {x, y} = pos ->
      in_range(pos, range) and !MapSet.member?(cluster, pos) and
        M2.get!(guarden, x, y) == label
    end)
  end

  defp count_primeter(name, pos, input) do
    length(get_parimeters(name, pos, input))
  end

  defp get_parimeters(name, pos, input) do
    Enum.filter(@directions, fn d -> has_perimerter_in_direction?(name, pos, d, input) end)
  end

  defp has_perimerter_in_direction?(name, start, direction, {regions, range}) do
    {xn, yn} = next = go_direction(start, direction)

    if !in_range(next, range) do
      true
    else
      name_next = M2.get!(regions, xn, yn)
      name != name_next
    end
  end

  defp go_direction({x, y}, {dx, dy}) do
    {x + dx, y + dy}
  end

  defp in_range({x, y}, range) do
    x in range and y in range
  end

  # Did not finish
  def p2 do
    {guarden, range, by_label} = get_input("12tt")

    {label, positions} = hd(Map.to_list(by_label))
    # |> Enum.map(fn {label, positions} ->
    find_clusters(label, positions, [], {guarden, range})
    |> Enum.map(fn cluster -> count_sides(label, cluster, {guarden, range}) end)
    # end)
    |> IO.inspect()
  end

  defp count_sides(label, cluster, input) do
    tiles =
      MapSet.to_list(cluster)
      |> Enum.filter(&on_perimeter?(label, &1, input))

    verticals = Enum.group_by(tiles, fn {x, _} -> x end)
    horizontals = Enum.group_by(tiles, fn {_, y} -> y end)

    IO.inspect(label)
    IO.inspect(verticals, label: "verticals")
    IO.inspect(horizontals, label: "horizontals")

    # count_horizontal(label, tiles, input)
    # count_vertical(label, tiles, input)
  end

  defp on_perimeter?(name, pos, input) do
    count_primeter(name, pos, input) > 0
  end
end

D12.p1()
D12.p2()
