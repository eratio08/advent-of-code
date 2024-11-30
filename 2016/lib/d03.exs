defmodule D03 do
  def p1() do
    possible =
      Helpers.get_lines(3)
      |> Stream.map(&build_triangle/1)
      |> Stream.filter(&is_triange/1)
      |> Enum.to_list()
      |> length()

    IO.puts(possible)
  end

  defp build_triangle(l) do
    String.split(l, " ", trim: true) |> Enum.map(&String.to_integer/1)
  end

  defp is_triange([a, b, c]) do
    a + b > c and b + c > a and c + a > b
  end
end

D03.p1()
