defmodule Day02 do
  # 1 2 3
  # 4 5 6
  # 7 8 9
  def part_1() do
    code =
      Helpers.get_input("2")
      |> String.split("\n")
      # drop empty lines
      |> Stream.filter(&not_empty/1)
      |> Stream.map(&String.split(&1, ""))
      # drop empty positions
      |> Stream.map(fn l -> Enum.filter(l, &not_empty/1) end)
      |> Stream.map(&encode_moves/1)
      |> Enum.reduce([5], &find_num/2)
      |> Enum.reverse()
      # drop the initial number
      |> Enum.drop(1)
      |> Enum.join()

    IO.puts(code)
  end

  defp not_empty(s) do
    s != ""
  end

  defp find_num(line, [p | _] = acc) do
    num =
      line
      |> List.foldl(p, fn m, p -> move(p, m) end)

    [num | acc]
  end

  defp encode_moves(l) do
    Enum.map(l, fn m -> encode_move(m) end)
  end

  defp encode_move(move) do
    case move do
      "U" -> -3
      "R" -> +1
      "D" -> +3
      "L" -> -1
    end
  end

  defp move(p, m) do
    if p < 1 or p > 9 do
      throw("Illegal previous position #{p}")
    end

    case {p, m} do
      {x, -1} when x in [1, 4, 7] ->
        p

      {x, 1} when x in [3, 6, 9] ->
        p

      _ ->
        next = p + m

        cond do
          next < 1 or next > 9 ->
            p

          true ->
            next
        end
    end
  end
end

Day02.part_1()
