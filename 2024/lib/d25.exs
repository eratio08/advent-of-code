defmodule D25 do
  def p1 do
    parse_input("25") |> count_pairs |> IO.inspect()
  end

  defp count_pairs({keys, locks}) do
    import Bitwise

    Enum.reduce(locks, 0, fn lock, cnt ->
      Enum.reduce(keys, cnt, fn key, cnt ->
        if (lock &&& key) == 0 do
          cnt + 1
        else
          cnt
        end
      end)
    end)
  end

  defp parse_input(day) do
    bytes = Helpers.get_input(day)
    parse_input(bytes, [], [])
  end

  defp parse_input(<<>>, keys, locks) do
    {keys, locks}
  end

  # zeros will filter mask the newline bits
  @mask 0b011111_011111_011111_011111_011111

  # Idea: Every line can be interpreted as a binary.
  # Each lines begins with a newline which will be masked later.
  # Build the binary by taking the LSB of the binary representation of the character.
  # Find the two binary numbers that will be zero if combined using binary-or.
  defp parse_input(bytes, keys, locks) do
    import Bitwise

    # skip first row, bits 0..5, next start with newline
    bits =
      String.slice(bytes, 5..34)
      |> to_bits(0)

    {keys, locks} =
      case bytes do
        <<"#", _rest::binary>> -> {keys, [bits &&& @mask | locks]}
        _ -> {[bits &&& @mask | keys], locks}
      end

    # skip the last row, bit 35..41 + \n
    from = min(byte_size(bytes), 43)
    to = byte_size(bytes)
    bytes = String.slice(bytes, from..to)

    parse_input(bytes, keys, locks)
  end

  defp to_bits(<<>>, bits), do: bits

  defp to_bits(<<n, rest::binary>>, bits) do
    import Bitwise

    # build up bits by appending LSB of n
    # "." is 46 is 0b101110 -> LSB = 0
    # "#" is 35 is 0b100011 -> LSB = 1
    to_bits(rest, bits <<< 1 ||| (n &&& 1))
  end

  def p2 do
  end
end

D25.p1()
D25.p2()
