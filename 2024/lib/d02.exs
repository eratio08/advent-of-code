defmodule D02 do
  def p1() do
    safe =
      Helpers.get_lines("2")
      |> Stream.map(&build_readings/1)
      |> Stream.map(&build_windowed/1)
      |> Stream.map(&diff/1)
      |> Stream.filter(&is_safe/1)
      |> Enum.to_list()
      |> length()

    IO.puts(safe)
  end

  defp build_readings(l) do
    String.split(l, " ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp build_windowed(l) do
    Enum.chunk_every(l, 2, 1, :discard)
  end

  defp diff(l) do
    Enum.map(l, fn [a, b] -> a - b end)
  end

  defp is_safe(l) do
    {is_safe, _} =
      Enum.reduce(l, {true, nil}, fn
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
      Helpers.get_lines("2t")
      |> Stream.map(&build_readings/1)
      |> Stream.map(&build_windowed/1)
      |> Stream.map(&diff/1)
      # |> Stream.filter(&is_safe_corrected(&1, nil, false, true))
      |> Stream.filter(&is_safe_2/1)
      |> Enum.to_list()
      |> length()

    IO.puts(safe)
  end

  defp is_safe_2(l) do
    {is_safe, _, _} =
      Enum.reduce(l, {true, false, nil}, fn
        _, {false, _, _} = acc -> acc
        n, {acc, c, nil} when n < 0 -> {acc, c, :neg}
        n, {acc, c, nil} when n > 0 -> {acc, c, :pos}
        n, {_, false, d} when n == 0 or abs(n) > 3 -> {true, true, d}
        n, {_, true, d} when n == 0 or abs(n) > 3 -> {false, true, d}
        n, {_, false, :pos} when n < 0 -> {true, true, :pos}
        n, {_, true, :pos} when n < 0 -> {false, true, :pos}
        n, {_, false, :neg} when n > 0 -> {true, true, :neg}
        n, {_, true, :neg} when n > 0 -> {false, true, :net}
        _, acc -> acc
      end)

    IO.inspect({l, is_safe})
    is_safe
  end
end

D02.p1()
# D02.p2()
