defmodule D24 do
  def p1 do
    input = parse_input("24")

    apply_inputs(input.inputs, input.gates)
    |> Map.filter(fn {k, _v} -> String.starts_with?(k, "z") end)
    |> Map.to_list()
    |> Enum.sort(fn {a, _}, {b, _} -> a >= b end)
    |> Enum.map(fn {_k, v} -> v end)
    # |> Enum.reverse()
    |> Enum.reduce(0, fn b, acc ->
      import Bitwise

      case b do
        true -> IO.inspect(1)
        false -> IO.inspect(0)
      end

      case b do
        true -> (acc <<< 1) + 1
        false -> acc <<< 1
      end
    end)
    |> IO.inspect()
  end

  defp parse_input(day) do
    [inputs, gates] = Helpers.get_input(day) |> String.split("\n\n")

    inputs =
      String.split(inputs, "\n", trim: true)
      |> Enum.reduce(%{}, fn line, map ->
        [id, v] = String.split(line, ": ")

        v = v == "1"

        Map.put(map, id, v)
      end)

    gates =
      String.split(gates, "\n", trim: true)
      |> Enum.reduce(%{}, fn line, map ->
        [i1, op, i2, _, o] = String.split(line, " ")
        Map.put(map, o, {i1, op, i2})
      end)

    %{:inputs => inputs, :gates => gates}
  end

  defp apply_inputs(inputs, gates) do
    Map.keys(gates)
    |> Enum.reduce(inputs, fn wire, inputs ->
      {_v, inputs} = apply_input(inputs, gates, wire)
      inputs
    end)
  end

  defp apply_input(inputs, gates, wire) do
    case Map.get(inputs, wire) do
      nil ->
        {i1, op, i2} = Map.get(gates, wire)
        {v1, inputs} = apply_input(inputs, gates, i1)
        {v2, inputs} = apply_input(inputs, gates, i2)

        o =
          case op do
            "AND" -> v1 and v2
            "OR" -> v1 or v2
            "XOR" -> (v1 and !v2) or (!v1 and v2)
          end

        {o, Map.put(inputs, wire, o)}

      v ->
        {v, inputs}
    end
  end

  def p2 do
  end
end

D24.p1()
D24.p2()
