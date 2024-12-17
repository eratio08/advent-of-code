defmodule D17 do
  def p1 do
    {state, program} = parse_input("17")
    run(state, program).out |> Enum.join(",") |> IO.inspect()
  end

  defp run(state, program) do
    ipt = state.ipt

    if ipt >= tuple_size(program) do
      %{state | out: Enum.reverse(state.out)}
    else
      inst = elem(program, ipt)
      run(inst.(state), program)
    end
  end

  defp parse_input(day) do
    [registers, program] = Helpers.get_input(day) |> String.split("\n\n")

    state =
      registers
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{:ipt => 0, :out => []}, fn r, map ->
        [_, reg, value] = String.split(r, " ", trim: true)
        value = String.to_integer(value)

        case reg do
          "A:" -> Map.put(map, :a, value)
          "B:" -> Map.put(map, :b, value)
          "C:" -> Map.put(map, :c, value)
        end
      end)

    [_, program] = String.split(program, " ", trim: true)

    program =
      program
      |> String.replace("\n", "")
      |> String.split(",", trim: true)
      |> Stream.map(&String.to_integer/1)
      |> Stream.chunk_every(2)
      |> Stream.map(&to_instr/1)
      |> Enum.reduce({}, fn inst, acc -> Tuple.append(acc, inst) end)

    {state, program}
  end

  # adv
  defp to_instr([0, operand]) do
    import Bitwise

    fn state ->
      a = state.a
      b = combo_op(state, operand)
      r = a >>> b

      %{state | a: r, ipt: state.ipt + 1}
    end
  end

  # bxl
  defp to_instr([1, operand]) do
    import Bitwise

    fn state ->
      a = state.b
      b = operand
      r = bxor(a, b)

      %{state | b: r, ipt: state.ipt + 1}
    end
  end

  # bst
  defp to_instr([2, operand]) do
    import Bitwise

    fn state ->
      a = combo_op(state, operand)
      r = a &&& 7
      %{state | b: r, ipt: state.ipt + 1}
    end
  end

  # jnz
  defp to_instr([3, operand]) do
    import Bitwise

    fn state ->
      case state.a do
        0 ->
          %{state | ipt: state.ipt + 1}

        _ ->
          # as the list was halved when parsing instruction
          r = operand >>> 1
          %{state | ipt: r}
      end
    end
  end

  # bxc
  defp to_instr([4, _]) do
    import Bitwise

    fn state ->
      a = state.b
      b = state.c
      r = bxor(a, b)
      %{state | b: r, ipt: state.ipt + 1}
    end
  end

  # out
  defp to_instr([5, operand]) do
    import Bitwise

    fn state ->
      a = combo_op(state, operand)
      # n mod 8
      b = a &&& 7
      r = [b | state.out]
      %{state | out: r, ipt: state.ipt + 1}
    end
  end

  # bdv
  defp to_instr([6, operand]) do
    import Bitwise

    fn state ->
      a = state.a
      b = combo_op(state, operand)
      r = a >>> b
      %{state | b: r, ipt: state.ipt + 1}
    end
  end

  # cdv
  defp to_instr([7, operand]) do
    import Bitwise

    fn state ->
      a = state.a
      b = combo_op(state, operand)
      r = a >>> b
      %{state | c: r, ipt: state.ipt + 1}
    end
  end

  defp combo_op(state, operand) do
    case operand do
      op when op in 0..3 ->
        op

      4 ->
        state.a

      5 ->
        state.b

      6 ->
        state.c
    end
  end

  def p2 do
  end
end

D17.p1()
D17.p2()
