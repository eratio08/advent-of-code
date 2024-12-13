defmodule D13 do
  def p1 do
    parse_input("13")
    |> Enum.reduce(0, fn [p, b, a], acc ->
      calc(a, b, p) + acc
    end)
    |> IO.inspect()
  end

  defp parse_input(day) do
    Helpers.get_lines_strm(day)
    |> Enum.to_list()
    |> List.foldl([[]], fn
      "", [cur | rest] ->
        [[], cur | rest]

      l, [cur | rest] ->
        [[parse_line(l) | cur] | rest]
    end)
  end

  defp parse_line(line) do
    case String.split(line, " ", trim: true) do
      ["Button", "A:", x, y] ->
        {:A, x |> String.replace(",", "") |> String.replace("X+", "") |> String.to_integer(),
         y |> String.replace("Y+", "") |> String.to_integer()}

      ["Button", "B:", x, y] ->
        {:B, x |> String.replace(",", "") |> String.replace("X+", "") |> String.to_integer(),
         y |> String.replace("Y+", "") |> String.to_integer()}

      ["Prize:", x, y] ->
        {:P, x |> String.replace(",", "") |> String.replace("X=", "") |> String.to_integer(),
         y |> String.replace("Y=", "") |> String.to_integer()}
    end
  end

  defp calc({:A, ax, ay}, {:B, bx, by}, {:P, px, py}) do
    # ax*i+bx*j=px
    # ay*i+by*j=py
    det = ax * by - bx * ay
    i = round((by * px - bx * py) / det)
    j = round((-ay * px + ax * py) / det)

    if ax * i + bx * j == px and ay * i + by * j == py do
      # A 1 Token
      # B 3 Token
      i * 3 + j
    else
      0
    end
  end

  def p2 do
    parse_input("13")
    |> Enum.reduce(0, fn [{:P, px, py}, b, a], acc ->
      calc(a, b, {:P, px + 10_000_000_000_000, py + 10_000_000_000_000}) + acc
    end)
    |> IO.inspect()
  end
end

D13.p1()
D13.p2()
