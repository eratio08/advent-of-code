defmodule D09 do
  def p1() do
    model = parse("9")
    {res, cnt} = compact(model, Enum.reverse(model), [], 0)
    compacted = Enum.take(res, length(res) - cnt)

    checksum = checksum(compacted)

    IO.inspect(checksum)
  end

  defp checksum(compacted) do
    compacted
    |> Enum.with_index()
    |> Enum.reduce(0, fn
      {".", _}, sum -> sum
      {id, pos}, sum -> id * pos + sum
    end)
  end

  defp repeat(_, 0), do: []
  defp repeat(x, n), do: for(_ <- 1..n, do: x)

  defp parse(day) do
    Helpers.get_input(day)
    |> String.replace("\n", "")
    |> String.split("", trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index()
    |> Enum.reduce([], fn {b, p}, acc ->
      case Integer.mod(p, 2) do
        0 ->
          acc ++ repeat(div(p, 2), b)

        1 ->
          acc ++ repeat(".", b)
      end
    end)
  end

  defp compact([], _, res, cnt) do
    {res, cnt}
  end

  defp compact(_, [], res, cnt) do
    {res, cnt}
  end

  defp compact(["." | _] = l, ["." | rest2], res, cnt) do
    compact(l, rest2, res, cnt)
  end

  defp compact(["." | rest1], [n | rest2], res, cnt) do
    compact(rest1, rest2, res ++ [n], cnt + 1)
  end

  defp compact([n | rest1], l, res, cnt) do
    compact(rest1, l, res ++ [n], cnt)
  end

  def p2() do
    model = parse_2("9")
    rev_model = Enum.reverse(model)
    compacted = compact_2(rev_model, model)
    expanded = expand(compacted)
    IO.inspect(checksum(expanded))
  end

  defp parse_2(day) do
    Helpers.get_input(day)
    |> String.replace("\n", "")
    |> String.split("", trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Stream.with_index()
    |> Enum.map(fn {blocks, pos} ->
      case Integer.mod(pos, 2) do
        0 ->
          id = div(pos, 2)
          {0, [{id, blocks}]}

        1 ->
          {blocks, []}
      end
    end)
  end

  defp compact_2([], model) do
    model
  end

  defp compact_2([hd | rest], model) do
    model = try_insert(hd, model, [], true)
    compact_2(rest, model)
  end

  defp try_insert({0, [{id, n}]} = a, [block | rest], res, insert) do
    case block do
      ^a when not insert ->
        try_insert(a, rest, [{n, []} | res], insert)

      ^a ->
        try_insert(a, rest, [a | res], false)

      {m, l} when m >= n and insert ->
        try_insert(a, rest, [{m - n, l ++ [{id, n}]} | res], false)

      {_, _} = b ->
        try_insert(a, rest, [b | res], insert)
    end
  end

  defp try_insert(_, [], res, _) do
    res |> Enum.reverse()
  end

  defp try_insert({_, _}, blocks, _, _) do
    blocks
  end

  defp expand(model) do
    List.foldr(model, [], fn {free, l}, acc ->
      Enum.flat_map(l, fn {id, n} -> repeat(id, n) end) ++ repeat(".", free) ++ acc
    end)
  end
end

D09.p1()
D09.p2()
