defmodule D21 do
  def p1 do
    {sum, _memo} =
      parse_input("21")
      |> Enum.reduce({0, %{}}, fn code, {cmpl, memo} ->
        {length, memo} = shortest(code, 2, 2, memo)
        num = Enum.take(code, 3) |> Enum.join() |> String.to_integer()
        {cmpl + num * length, memo}
      end)

    sum |> IO.inspect()
  end

  defp parse_input(day) do
    Helpers.get_lines_strm(day)
    |> Stream.map(fn l -> String.split(l, "", trim: true) end)
    |> Enum.to_list()
  end

  @pos %{
    # :num
    "7" => {0, 0},
    "8" => {1, 0},
    "9" => {2, 0},
    "4" => {0, 1},
    "5" => {1, 1},
    "6" => {2, 1},
    "1" => {0, 2},
    "2" => {1, 2},
    "3" => {2, 2},
    "0" => {1, 3},
    "A" => {2, 3},
    # :dir
    "^" => {1, 0},
    "a" => {2, 0},
    "<" => {0, 1},
    "v" => {1, 1},
    ">" => {2, 1}
  }
  @directions %{
    "^" => {0, -1},
    ">" => {1, 0},
    "v" => {0, 1},
    "<" => {-1, 0}
  }

  defp shortest(code, n, fst, memo) do
    # check if memoized
    case Map.get(memo, {code, n}) do
      nil ->
        {kp, start} =
          case n do
            ^fst -> {:num, Map.get(@pos, "A")}
            _ -> {:dir, Map.get(@pos, "a")}
          end

        {length, memo, _next} =
          Enum.reduce(code, {0, memo, start}, fn c, {length, memo, cur} ->
            next = Map.get(@pos, c)
            paths = paths_to(cur, next, kp)

            # in last round of encoding
            if n == 0 do
              {length + length(hd(paths)), memo, next}
            else
              # find shortest in next encoding round
              {lengths, memo} =
                Enum.reduce(paths, {[], memo}, fn path, {lengths, memo} ->
                  {length, memo} = shortest(path, n - 1, fst, memo)
                  {[length | lengths], memo}
                end)

              min = Enum.min(lengths)
              {length + min, memo, next}
            end
          end)

        {length, Map.put(memo, {code, n}, length)}

      length ->
        {length, memo}
    end
  end

  defp paths_to({sx, sy} = start, {fx, fy}, kp) do
    path_x =
      case fx - sx do
        dx when dx <= 0 -> List.duplicate("<", abs(dx))
        dx -> List.duplicate(">", dx)
      end

    path_y =
      case fy - sy do
        dy when dy <= 0 -> List.duplicate("^", abs(dy))
        dy -> List.duplicate("v", dy)
      end

    # general required moves due to taxi metric
    path = path_x ++ path_y
    # all possible moves, including illegal
    all_path = permutations(path) |> MapSet.new() |> MapSet.to_list()

    allowed_path =
      Enum.filter(all_path, fn path ->
        # find legal paths by excluding path with illegal steps
        Enum.reduce_while(path, start, fn move, {x, y} ->
          {dx, dy} = Map.get(@directions, move)
          next = {x + dx, y + dy}

          if in_range?(next, kp) and valid?(next, kp) do
            {:cont, next}
          else
            {:halt, nil}
          end
        end) != nil
      end)

    # append the 'A' as this is pressed at the end
    Enum.map(allowed_path, fn p -> p ++ ["a"] end)
  end

  defp in_range?({x, y}, :num), do: x in 0..2 and y in 0..3
  defp in_range?({x, y}, :dir), do: x in 0..2 and y in 0..1

  defp valid?({0, 3}, :num), do: false
  defp valid?({0, 0}, :dir), do: false
  defp valid?(_pos, _kp), do: true

  # 🤯 mind-bending
  # equivalent to:
  # def permutations([]), do: [[]]
  # def permutations(list) do
  #   Enum.reduce(list, [], fn elem, acc ->
  #     rest_permutations = permutations(list -- [elem])
  #     new_permutations = Enum.map(rest_permutations, fn rest -> [elem | rest] end)
  #     acc ++ new_permutations
  #   end)
  # end
  def permutations([]), do: [[]]

  def permutations(list) do
    for elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest]
  end

  def p2 do
    {sum, _memo} =
      parse_input("21")
      |> Enum.reduce({0, %{}}, fn code, {cmpl, memo} ->
        {length, memo} = shortest(code, 25, 25, memo)
        num = Enum.take(code, 3) |> Enum.join() |> String.to_integer()
        {cmpl + num * length, memo}
      end)

    sum |> IO.inspect()
  end
end

D21.p1()
D21.p2()
