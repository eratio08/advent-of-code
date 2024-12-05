defmodule D05 do
  def p1() do
    {rules, pages} =
      Helpers.get_lines("5")
      |> parse_input()

    rules_dict = make_rules_dict(rules)
    rightly_ordered = pages |> Enum.filter(&is_rightly_ordered(&1, rules_dict))

    res = middle_value_sum(rightly_ordered)
    IO.inspect(res)
  end

  defp parse_input(ls) do
    rules =
      ls
      |> Stream.take_while(fn l -> String.length(l) == 5 end)
      |> Stream.map(fn l ->
        [a, b] = String.split(l, "|", trim: true)
        {String.to_integer(a), String.to_integer(b)}
      end)
      |> Enum.to_list()

    pages =
      ls
      |> Stream.drop_while(fn l -> String.length(l) == 5 end)
      |> Stream.map(fn l -> String.split(l, ",", trim: true) end)
      |> Stream.map(fn l -> Enum.map(l, &String.to_integer/1) end)
      |> Enum.to_list()

    {rules, pages}
  end

  defp make_rules_dict(rules) do
    rules
    |> Enum.reduce(%{}, fn {a, b}, dict ->
      Map.update(dict, a, MapSet.new([b]), fn s -> MapSet.put(s, b) end)
    end)
  end

  defp is_rightly_ordered(page_update, rules_dict) do
    sorted = sort_page_update(page_update, rules_dict)
    Enum.zip(page_update, sorted) |> Enum.reduce(true, fn {a, b}, acc -> a == b and acc end)
  end

  defp sort_page_update(page_update, rules_dict) do
    page_update
    |> Enum.sort(fn a, b ->
      rules_for_a = Map.get(rules_dict, a, MapSet.new())
      b_after_a = MapSet.member?(rules_for_a, b)

      if !b_after_a do
        rules_for_b = Map.get(rules_dict, b, MapSet.new())
        a_after_b = MapSet.member?(rules_for_b, a)
        # if both are false do not change position
        a_after_b == b_after_a
      else
        b_after_a
      end
    end)
  end

  defp middle_value_sum(l) do
    l
    |> Stream.map(fn l ->
      pos = trunc(length(l) / 2)
      Enum.at(l, pos)
    end)
    |> Enum.sum()
  end

  def p2() do
    {rules, pages} =
      Helpers.get_lines("5")
      |> parse_input()

    rules_dict = make_rules_dict(rules)

    incorrect = pages |> Enum.filter(fn l -> !is_rightly_ordered(l, rules_dict) end)
    sorted = incorrect |> Enum.map(&sort_page_update(&1, rules_dict))
    res = middle_value_sum(sorted)

    IO.inspect(res)
  end
end

D05.p1()
D05.p2()
