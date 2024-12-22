defmodule D22 do
  def p1 do
    get_input("22")
    |> Stream.map(&secret(&1, 2000))
    |> Enum.sum()
    |> IO.inspect()
  end

  defp get_input(day) do
    Helpers.get_lines_strm(day) |> Stream.map(&String.to_integer/1)
  end

  defp secret(start, 0) do
    start
  end

  defp secret(start, rounds) do
    secret(next(start), rounds - 1)
  end

  defp next(start) do
    import Bitwise
    # 2^6 = 64, 16^6 = 16_777_216
    a = bxor(start <<< 6, start) &&& 0xFFFFFF
    # 2^5 = 32
    b = bxor(a >>> 5, a) &&& 0xFFFFFF
    # 2^11 = 2048
    bxor(b <<< 11, b) &&& 0xFFFFFF
  end

  defp secrets(_start, 0, acc) do
    acc |> Enum.reverse()
  end

  defp secrets(start, n, acc) do
    next = next(start)
    secrets(next, n - 1, [start | acc])
  end

  def p2 do
    prices_by_comb_of_secrets =
      get_input("22")
      |> Enum.map(&prices_for_secret/1)

    uniq_comb = Stream.flat_map(prices_by_comb_of_secrets, &Map.keys/1) |> Enum.uniq()

    max =
      uniq_comb
      |> Stream.map(fn comb ->
        {comb,
         prices_by_comb_of_secrets
         # Get prices for combination for each secret
         |> Stream.map(fn prices_by_comb -> Map.get(prices_by_comb, comb, 0) end)
         # Get total price of combination
         |> Enum.sum()}
      end)
      |> Enum.max(fn {_, a}, {_, b} -> a >= b end)

    IO.inspect(max)
  end

  defp last_digit(n), do: rem(n, 10)

  defp changes(prices) do
    prices
    |> Stream.chunk_every(2, 1, :discard)
    |> Stream.map(fn [a, b] -> b - a end)
    |> Enum.to_list()
  end

  defp prices_for_secret(start) do
    secrets = secrets(start, 2000, [])
    prices = Enum.map(secrets, &last_digit/1)
    changes = changes(prices)
    prices_tup = Enum.reduce(prices, {}, fn d, acc -> Tuple.append(acc, d) end)

    changes
    # first price to look at after 4
    |> Enum.chunk_every(4, 1, :discard)
    |> Enum.with_index()
    # store combination and price
    |> Enum.reduce(%{}, fn {changes, i}, map ->
      # price after 4 changes
      Map.put(map, changes, elem(prices_tup, i + 4))
    end)
  end
end

D22.p1()
D22.p2()
