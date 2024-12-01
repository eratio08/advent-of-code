defmodule D01 do
  def p1() do
    {l1, l2} =
      Helpers.get_lines("1")
      |> Enum.reduce({[], []}, &build_lists/2)

    l1 = Enum.sort(l1)
    l2 = Enum.sort(l2)

    total_distance =
      Stream.zip(l1, l2)
      |> Stream.map(fn {n1, n2} -> abs(n1 - n2) end)
      |> Enum.sum()

    IO.puts(total_distance)
  end

  defp build_lists(l, {l1, l2}) do
    [n1, n2] = String.split(l, "  ", trim: true)
    n1 = String.trim(n1) |> String.to_integer()
    n2 = String.trim(n2) |> String.to_integer()
    {[n1 | l1], [n2 | l2]}
  end

  def p2() do
    {l1, l2} =
      Helpers.get_lines("1")
      |> Enum.reduce({[], []}, &build_lists/2)

    ml =
      l1
      |> Enum.reduce(%{}, fn n, acc -> Map.update(acc, n, {1, 0}, fn {n, 0} -> {n + 1, 0} end) end)

    similarity =
      l2
      |> Enum.reduce(ml, fn n, ml ->
        Map.update(ml, n, {0, 0}, fn
          {0, 0} -> {0, 0}
          {m, v} -> {m, v + n}
        end)
      end)
      |> Map.values()
      |> Enum.reduce(0, fn {m, v}, acc -> m * v + acc end)

    IO.puts(similarity)
  end
end

D01.p1()
D01.p2()
