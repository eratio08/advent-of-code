defmodule D19 do
  def p1 do
    {towels, designs} = parse_input("19")

    designs
    |> Enum.map(fn design ->
      {count, _} = dfs(towels, design, %{"" => 1}, 0)
      count
    end)
    |> Enum.count(fn x -> x > 0 end)
    |> IO.inspect()
  end

  defp parse_input(day) do
    [towels, designs] = Helpers.get_input(day) |> String.split("\n\n")
    towels = towels |> String.split(", ", trim: true)

    designs =
      designs |> String.split("\n", trim: true)

    {towels, designs}
  end

  # Idea: the design is like a path and the towels are steps
  # Can you find a way through the design using towel-steps?
  # Dynamic programming to safe time.
  defp dfs(towels, design, memo, count) do
    case Map.get(memo, design) do
      nil ->
        {new_count, memo} =
          towels
          |> Enum.reduce({count, memo}, fn towel, {count, memo} ->
            # can walk?
            if String.starts_with?(design, towel) do
              rest = String.slice(design, String.length(towel), String.length(design))
              {cnt, memo} = dfs(towels, rest, memo, 0)
              {count + cnt, memo}
            else
              {count, memo}
            end
          end)

        {new_count, Map.put(memo, design, new_count)}

      existing_count ->
        {existing_count, memo}
    end
  end

  def p2 do
    {towels, designs} = parse_input("19")

    designs
    |> Enum.map(fn design ->
      {count, _} = dfs(towels, design, %{"" => 1}, 0)
      count
    end)
    |> Enum.sum()
    |> IO.inspect()
  end
end

D19.p1()
D19.p2()
