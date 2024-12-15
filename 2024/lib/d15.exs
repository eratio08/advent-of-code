defmodule D15 do
  def p1 do
    {start, map, moves} = parse_input("15", fn x -> [x] end)

    {_, map} = Enum.reduce(moves, {start, map}, &move/2)

    IO.inspect(calc_score(map))
  end

  defp parse_input(day, expand_fn) do
    [map, moves] = Helpers.get_input(day) |> String.split("\n\n")

    map =
      map
      |> String.split("\n", trim: true)
      |> Enum.map(&(String.split(&1, "", trim: true) |> Enum.flat_map(expand_fn)))
      |> M2.new()

    {{x, y} = start, _} =
      M2.as_list_pos(map)
      |> Enum.find(false, fn
        {_, "@"} -> true
        _ -> false
      end)

    map = M2.put!(map, x, y, ".")

    moves = String.replace(moves, "\n", "") |> String.split("", trim: true)
    {start, map, moves}
  end

  defp move(move, {cur, map}) do
    {x, y} = next = next(cur, move)

    case M2.get!(map, x, y) do
      "#" -> {cur, map}
      "." -> {next, map}
      "O" -> push_box(move, cur, next, map)
      "[" -> push_big_box(move, cur, next, map)
      "]" -> push_big_box(move, cur, next, map)
    end
  end

  defp next({x, y}, move) do
    case move do
      "^" -> {x, y - 1}
      ">" -> {x + 1, y}
      "v" -> {x, y + 1}
      "<" -> {x - 1, y}
    end
  end

  defp push_box(move, cur, {bx, by} = box, map) do
    case find_space(move, box, map) do
      :no_space -> {cur, map}
      {sx, sy} -> {box, map |> M2.put!(bx, by, ".") |> M2.put!(sx, sy, "O")}
    end
  end

  defp find_space(move, {x, y} = cur, map) do
    case M2.get!(map, x, y) do
      "#" -> :no_space
      "O" -> find_space(move, next(cur, move), map)
      "." -> cur
    end
  end

  # Does not work as shifting by row or column is not enough
  defp push_big_box(move, cur, {bx, by} = box, map) do
    edge = M2.get!(map, bx, by)

    case find_big_space(move, edge, box, map) do
      :no_space ->
        {cur, map}

      {:horz, space} ->
        {box, shift_horizontal(box, space, map)}

      {space, space_2} ->
        box_2 =
          case edge do
            # ->
            "[" -> next(box, ">")
            # <-
            "]" -> next(box, "<")
          end

        map = shift_vertical(box, space, map)
        map = shift_vertical(box_2, space_2, map)
        {box, map}
    end
  end

  defp find_big_space(move, edge, {x, y} = cur, map) do
    check_next = fn {nx, ny} = next ->
      case M2.get!(map, nx, ny) do
        "#" -> :no_space
        "." -> {cur, next}
        _ -> :no_space
      end
    end

    case M2.get!(map, x, y) do
      "#" ->
        :no_space

      "." ->
        cond do
          move in ["<", ">"] ->
            {:horz, cur}

          true ->
            case edge do
              # ->
              "[" -> check_next.(next(cur, ">"))
              # <-
              "]" -> check_next.(next(cur, "<"))
            end
        end

      _ ->
        find_big_space(move, edge, next(cur, move), map)
    end
  end

  defp shift_vertical({fx, fy}, {_, ty}, map) do
    {vs, map} =
      fy..ty
      |> Enum.reduce({nil, map}, fn
        y, {nil, map} ->
          {M2.get!(map, fx, y), map}

        y, {vp, map} ->
          vf = M2.get!(map, fx, y)
          {vf, M2.put!(map, fx, y, vp)}
      end)

    map |> M2.put!(fx, fy, vs)
  end

  defp shift_horizontal({fx, fy}, {tx, _}, map) do
    {vs, map} =
      fx..tx
      |> Enum.reduce({nil, map}, fn
        x, {nil, map} ->
          {M2.get!(map, x, fy), map}

        x, {vp, map} ->
          vf = M2.get!(map, x, fy)
          {vf, M2.put!(map, x, fy, vp)}
      end)

    map |> M2.put!(fx, fy, vs)
  end

  defp calc_score(map) do
    M2.as_list_pos(map)
    |> Enum.filter(fn
      {_, "O"} -> true
      _ -> false
    end)
    |> Enum.reduce(0, fn {{x, y}, _}, acc -> x + y * 100 + acc end)
  end

  def p2 do
    {start, map, moves} =
      parse_input("15ttt", fn
        "#" -> ["#", "#"]
        "@" -> ["@", "."]
        "O" -> ["[", "]"]
        "." -> [".", "."]
      end)

    IO.inspect([start, map, moves])

    # shift_vertical({9, 3}, {9, 5}, map) |> IO.inspect()
    # shift_vertical({8, 3}, {8, 5}, map) |> IO.inspect()

    {_, map} = Enum.reduce(Enum.take(moves, 6), {start, map}, &move/2)
    IO.inspect(map)

    #
    # IO.inspect(calc_score(map))
  end
end

D15.p1()
# D15.p2()
