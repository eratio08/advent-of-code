defmodule D04 do
  def p1() do
    lines = Helpers.get_lines("4")

    h_cnt = lines |> count_lines()
    v_cnt = lines |> rotate(:vertical) |> count_lines()
    d_tl_cnt = lines |> rotate(:diagonal_tl) |> count_lines()
    d_tr_cnt = lines |> rotate(:diagonal_tr) |> count_lines()

    IO.inspect(h_cnt + v_cnt + d_tl_cnt + d_tr_cnt)
  end

  defp rotate(lines, :vertical) do
    h = length(lines) - 1

    for x <- 0..h,
        do: for(y <- 0..h, line = Enum.at(lines, y), do: String.at(line, x)) |> Enum.join()
  end

  defp rotate(lines, :diagonal_tl) do
    h = length(lines) - 1

    top_left_1 =
      for s <- 0..h,
          do:
            for(
              x <- s..0,
              y = s - x,
              line = Enum.at(lines, y),
              do: String.at(line, x)
            )
            |> Enum.join()

    top_left_2 =
      for s <- 1..h,
          do:
            for(
              x <- h..s,
              y = h - x + s,
              line = Enum.at(lines, y),
              do: String.at(line, x)
            )
            |> Enum.join()

    top_left_1 ++ top_left_2
  end

  defp rotate(lines, :diagonal_tr) do
    h = length(lines) - 1

    top_right_1 =
      for s <- h..0,
          do:
            for(
              x <- s..h,
              y = x - s,
              line = Enum.at(lines, y),
              do: String.at(line, x)
            )
            |> Enum.join()

    top_right_2 =
      for s <- (h - 1)..0,
          do:
            for(
              x <- 0..s,
              y = h - s + x,
              line = Enum.at(lines, y),
              do: String.at(line, x)
            )
            |> Enum.join()

    top_right_1 ++ top_right_2
  end

  defp count_lines(lines, word \\ "XMAS") do
    lines |> Enum.map(&count(&1, word)) |> Enum.sum()
  end

  defp count(line, word) do
    import Exp
    word_p = fn w -> many(string(w) ||| item() ~>> fn _ -> return(".") end) end
    word_rev_p = word_p.(String.reverse(word))
    [{match_word, ""}] = word_p.(word).(line)
    [{match_word_rev, ""}] = word_rev_p.(line)
    (match_word ++ match_word_rev) |> Enum.filter(fn n -> n != "." end) |> length()
  end

  # Using this approach in p1 would have been great :D
  def p2() do
    lines = Helpers.get_lines("4")
    l = length(lines)

    chars = lines |> Enum.map(&String.split(&1, "", trim: true))

    r = 0..(l - 1)

    as =
      for y <- r,
          x <- r,
          at(chars, x, y) == "A",
          do: xmas_cnt(chars, r, x, y)

    as = Enum.filter(as, fn cnt -> cnt == 2 end) |> length()

    IO.inspect(as)
  end

  defp xmas_cnt(chars, range, x, y) do
    cross = [
      # tl
      {{-1, -1}, {1, 1}},
      # bl
      {{-1, 1}, {1, -1}},
      # tr
      {{1, -1}, {-1, 1}},
      # br
      {{1, 1}, {-1, -1}}
    ]

    cross
    |> Stream.map(fn {{sx, sy}, {ex, ey}} -> {{x + sx, y + sy}, {x + ex, y + ey}} end)
    |> Stream.filter(fn {{sx, sy}, {ex, ey}} ->
      sx in range and sy in range and ex in range and
        ey in range
    end)
    |> Enum.reduce(0, fn
      {{sx, sy}, {ex, ey}}, cnt ->
        s = at(chars, sx, sy)
        e = at(chars, ex, ey)

        case {s, e} do
          {"M", "S"} -> cnt + 1
          _ -> cnt
        end
    end)
  end

  defp at(ls, x, y), do: ls |> Enum.at(y) |> Enum.at(x)
end

D04.p1()
D04.p2()
