defmodule D16 do
  def p1 do
    input = parse_input("16")
    IO.inspect(input.start)
    IO.inspect(input.end)

    {score, path} = run_maze(input.start, input.end, input.walls, input.range)
    IO.inspect(path)
    IO.inspect(length(path) - 1)
    IO.inspect(score)
  end

  defp parse_input(day) do
    m2 =
      Helpers.get_m2(day)

    range = 0..(M2.height(m2) - 1)

    map =
      m2
      |> M2.as_list_pos()
      |> Enum.group_by(fn {_, value} -> value end, fn {pos, _} -> pos end)

    %{
      :start => hd(Map.get(map, "S")),
      :end => hd(Map.get(map, "E")),
      :walls => MapSet.new(Map.get(map, "#")),
      :range => range
    }
  end

  def run_maze(start, goal, walls, range) do
    # {position, cost, direction}
    start_node = {start, 0, :east}
    priority_queue = [start_node]
    visited = %{start => 0}
    parents = %{start => nil}

    dijkstra(priority_queue, visited, parents, goal, walls, range)
  end

  defp dijkstra([], _visited, _parents, _goal, _walls, _range), do: :no_path

  defp dijkstra([head | rest] = _priority_queue, visited, parents, goal, walls, range) do
    {current_pos, current_cost, current_dir} = head

    if current_pos == goal do
      {current_cost, reconstruct_path(parents, {goal, current_dir, current_cost}, [])}
    else
      neighbors = get_neighbors(current_pos, walls, range)

      {queue, visited, parents} =
        walk(neighbors, current_pos, current_cost, current_dir, rest, visited, parents)

      dijkstra(queue, visited, parents, goal, walls, range)
    end
  end

  @directions [{{1, 0}, :east}, {{0, -1}, :north}, {{0, 1}, :south}, {{-1, 0}, :west}]

  defp get_neighbors(cur, walls, range) do
    @directions
    |> Enum.map(&move(cur, &1))
    |> Enum.filter(fn {{x, y}, _} ->
      in_range?(x, y, range) and can_move?(x, y, walls)
    end)
  end

  defp move({x, y}, {{dx, dy}, dir}), do: {{x + dx, y + dy}, dir}

  defp in_range?(x, y, range),
    do: x in range and y in range

  defp can_move?(x, y, walls), do: not MapSet.member?(walls, {x, y})

  defp walk(neighbors, current_pos, current_cost, current_dir, queue, visited, parents) do
    {queue, visited, parents} =
      Enum.reduce(neighbors, {queue, visited, parents}, fn {new_pos, new_dir},
                                                           {queue, visited, parents} ->
        new_cost = current_cost + 1 + turn_cost(current_dir, new_dir)

        if !Map.has_key?(visited, new_pos) or visited[new_pos] > new_cost do
          visited = Map.put(visited, new_pos, new_cost)
          queue = [{new_pos, new_cost, new_dir} | queue]
          parents = Map.put(parents, new_pos, {current_pos, current_dir, current_cost})
          {queue, visited, parents}
        else
          {queue, visited, parents}
        end
      end)

    # sort by cost, fake prio-queue
    queue = Enum.sort_by(queue, &elem(&1, 1))
    {queue, visited, parents}
  end

  defp turn_cost(current_dir, new_dir) when current_dir == new_dir, do: 0

  defp turn_cost(current_dir, new_dir) do
    case {current_dir, new_dir} do
      {:north, :south} -> 2000
      {:south, :north} -> 2000
      {:west, :east} -> 2000
      {:east, :west} -> 2000
      _ -> 1000
    end
  end

  defp reconstruct_path(_parents, nil, path) do
    Enum.reverse(path)
  end

  defp reconstruct_path(parents, {current, dir, cost}, path) do
    reconstruct_path(parents, Map.get(parents, current), [{current, dir, cost} | path])
  end

  def p2 do
  end
end

D16.p1()
D16.p2()
