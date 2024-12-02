defmodule D02 do
  def p1() do
    safe =
      Helpers.get_lines("2")
      |> Stream.map(&build_readings/1)
      |> Stream.filter(&is_safe/1)
      |> Enum.to_list()
      |> length()

    IO.puts(safe)
  end

  defp build_readings(l) do
    String.split(l, " ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp is_safe(l) do
    {is_safe, _} =
      l
      |> Stream.chunk_every(2, 1, :discard)
      |> Stream.map(fn [a, b] -> a - b end)
      |> Enum.reduce({true, nil}, fn
        _, {false, _} = acc -> acc
        n, _ when n == 0 or abs(n) > 3 -> {false, nil}
        n, {acc, nil} when n < 0 -> {acc, :neg}
        n, {acc, nil} when n > 0 -> {acc, :pos}
        n, {_, :pos} when n < 0 -> {false, nil}
        n, {_, :neg} when n > 0 -> {false, nil}
        _, acc -> acc
      end)

    is_safe
  end

  def p2() do
    safe =
      Helpers.get_lines("2")
      |> Stream.map(&build_readings/1)
      |> Stream.filter(&is_safe_2/1)
      |> Enum.to_list()
      |> length()

    IO.puts(safe)
  end

  defp is_safe_2(l) do
    empty =
      build_permutations(l) |> Enum.filter(&is_safe/1) |> Enum.empty?()

    !empty
  end

  defp build_permutations(l) do
    0..length(l)
    |> Enum.map(&permute_reading(l, &1))
  end

  defp permute_reading(l, i) do
    Stream.zip(0..length(l), l)
    |> Stream.filter(fn {j, _} -> i != j end)
    |> Enum.map(fn {_, n} -> n end)
  end
end

D02.p1()
D02.p2()
