defmodule D03 do
  def p1() do
    Helpers.get_lines("3")
    |> Enum.flat_map(&parse_muls/1)
    |> IO.inspect()
    |> Enum.sum()
    |> IO.inspect()
  end

  defp mul() do
    import Exp

    is_int = fn c -> c in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] end

    int =
      sat(is_int)

    valid_int =
      (count(3, int) ||| count(2, int) |||
         count(1, int))
      ~>> fn cs -> Enum.join(cs) |> String.to_integer() |> return end

    string("mul(")
    ~>> fn _ ->
      valid_int
      ~>> fn a ->
        string(",")
        ~>> fn _ ->
          valid_int
          ~>> fn b -> return(a * b) ~>> fn r -> string(")") ~>> fn _ -> return(r) end end end
        end
      end
    end
  end

  defp parse_muls(s) do
    import Exp
    mul_p = many(mul() ||| item() ~>> fn _ -> return(nil) end)
    [{match, ""}] = mul_p.(s)
    match |> Enum.filter(fn x -> not is_nil(x) end)
  end

  defp do_p() do
    import Exp
    string("do()") ~>> fn _ -> return(:do) end
  end

  defp dont_p() do
    import Exp
    string("don't()") ~>> fn _ -> return(:dont) end
  end

  defp parse_muls_2(s) do
    import Exp
    [{match, ""}] = many(do_p() ||| dont_p() ||| mul() ||| item() ~>> fn _ -> return(nil) end).(s)
    match |> Enum.filter(fn x -> not is_nil(x) end)
  end

  def p2() do
    {m, n} =
      Helpers.get_lines("3")
      |> Enum.flat_map(&parse_muls_2/1)
      |> IO.inspect()
      |> Enum.reduce({:do, []}, fn
        :do, {_, n} -> {:do, n}
        :dont, {_, n} -> {:dont, n}
        m, {:do, n} -> {:do, [m | n]}
        _, {:dont, n} -> {:dont, n}
      end)

    IO.inspect(m)
    IO.inspect(n, charlists: :as_lists)

    n
    |> Enum.sum()
    |> IO.inspect()
  end
end

D03.p1()
D03.p2()
