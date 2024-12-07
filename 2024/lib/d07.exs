defmodule D07 do
  def p1() do
    input = parse_input("7")

    res =
      input
      |> Stream.map(&find/1)
      |> Stream.filter(fn
        {:err} -> false
        _ -> true
      end)
      |> Enum.reduce(0, fn {:ok, res, _}, sum -> sum + res end)

    IO.inspect(res)
  end

  defp parse_input(day) do
    Helpers.get_lines_strm(day)
    |> Stream.map(fn l ->
      [res | [rest]] = String.split(l, ": ", trim: true)
      nums = String.split(rest, " ", trim: true)
      {String.to_integer(res), Enum.map(nums, &String.to_integer/1)}
    end)
  end

  defp find({res, [n | rest]}) do
    find_operators(res, rest, n, [])
  end

  defp find_operators(res, [], cur, ops) do
    if res == cur do
      {:ok, res, ops}
    else
      {:err}
    end
  end

  defp find_operators(res, nums, cur, ops) do
    [n | rest] = nums

    if cur >= res do
      {:err}
    end

    r = find_operators(res, rest, cur + n, [:add | ops])

    case r do
      {:err} ->
        find_operators(res, rest, cur * n, [:mul | ops])

      _ ->
        r
    end
  end

  def p2() do
    input = parse_input("7")

    res =
      input
      |> Stream.map(&find_2/1)
      |> Stream.map(&IO.inspect(&1))
      |> Stream.filter(fn
        {:err} -> false
        _ -> true
      end)
      # |> Stream.map(&IO.inspect(&1))
      |> Enum.reduce(0, fn {:ok, res, _}, sum -> sum + res end)

    IO.inspect(res)
  end

  defp find_2({res, [n | rest]}) do
    find_operators_2(res, rest, n, [])
  end

  defp concat_op(cur, n) do
    String.to_integer("#{Integer.to_string(cur)}#{Integer.to_string(n)}")
  end

  defp find_operators_2(res, [], cur, ops) do
    if res == cur do
      {:ok, res, ops}
    else
      {:err}
    end
  end

  defp find_operators_2(res, nums, cur, ops) do
    [n | rest] = nums

    if cur >= res do
      {:err}
    end

    r = find_operators_2(res, rest, cur + n, [:add | ops])

    case r do
      {:err} ->
        r = find_operators_2(res, rest, cur * n, [:mul | ops])

        case r do
          {:err} -> find_operators_2(res, rest, concat_op(cur, n), [:con | ops])
          _ -> r
        end

      _ ->
        r
    end
  end
end

D07.p1()
D07.p2()
