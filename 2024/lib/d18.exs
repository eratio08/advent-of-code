defmodule D18 do
  def p1 do
    walls = input("18")

    walls =
      walls
      |> Enum.take(1024)
      |> MapSet.new()

    limit = 70
    range = 0..limit

    run({0, 0}, {limit, limit}, walls, range)
    |> IO.inspect()
  end

  defp input(day) do
    Helpers.get_lines_strm(day)
    |> Stream.map(fn l ->
      [x, y] = String.split(l, ",", trim: true)
      {String.to_integer(x), String.to_integer(y)}
    end)
    |> Enum.to_list()
  end

  def run(start, goal, walls, range) do
    # {position, cost}
    start_node = {start, 0}
    priority_queue = [start_node]
    visited = %{start => 0}

    dijkstra(priority_queue, visited, goal, walls, range)
  end

  defp dijkstra([], _visited, _goal, _walls, _range), do: :no_path

  defp dijkstra([head | rest] = _priority_queue, visited, goal, walls, range) do
    {current_pos, current_cost} = head

    if current_pos == goal do
      current_cost
    else
      next = get_next(current_pos, walls, range)

      {queue, visited} =
        walk(next, current_cost, rest, visited)

      dijkstra(queue, visited, goal, walls, range)
    end
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

  defp get_next({x, y}, walls, range) do
    @directions
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.filter(fn {x, y} = next ->
      in_range = x in range and y in range
      can_move = not MapSet.member?(walls, next)
      in_range and can_move
    end)
  end

  defp walk(neighbors, current_cost, queue, visited) do
    {queue, visited} =
      Enum.reduce(neighbors, {queue, visited}, fn new_pos, {queue, visited} ->
        new_cost = current_cost + 1

        if !Map.has_key?(visited, new_pos) or visited[new_pos] > new_cost do
          visited = Map.put(visited, new_pos, new_cost)
          queue = [{new_pos, new_cost} | queue]
          {queue, visited}
        else
          {queue, visited}
        end
      end)

    queue = Enum.sort_by(queue, &elem(&1, 1))
    {queue, visited}
  end

  def p2 do
    bytes = input("18")

    limit = 70
    n = 1024
    range = 0..limit
    start = {0, 0}
    goal = {limit, limit}

    scenarios =
      Enum.map(n..(length(bytes) - 1), fn n -> {n, Enum.take(bytes, n) |> MapSet.new()} end)

    {n, _} =
      Enum.map(scenarios, fn {n, walls} ->
        Task.async(fn -> {n, run(start, goal, walls, range)} end)
      end)
      |> Task.await_many()
      |> Stream.filter(fn
        {_n, :no_path} -> true
        _ -> false
      end)
      |> Stream.take(1)
      |> Enum.to_list()
      |> hd()

    Enum.at(bytes, n - 1) |> IO.inspect()
  end
end

D18.p1()
D18.p2()
