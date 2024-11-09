defmodule Day01 do
  def get_input() do
    {:ok, bytes} = File.read("../input/d01")
    bytes

    # "R8, R4, R4, R8"
    # "R5, L5, R5, R3"
  end

  defmodule Point do
    defstruct x: 0, y: 0

    def new(x \\ 0, y \\ 0) do
      %Point{x: x, y: y}
    end

    def taxi_distance(%Point{} = a \\ %Point{x: 0, y: 0}, %Point{} = b) do
      abs(a.x - b.x) + abs(a.y - b.y)
    end

    def points_from_input(input) do
      {points, _} =
        String.replace(input, "\n", "")
        |> String.split(", ")
        |> Stream.map(&String.split_at(&1, 1))
        |> Stream.map(fn
          {"L", n} -> {:L, String.to_integer(n)}
          {"R", n} -> {:R, String.to_integer(n)}
        end)
        |> Enum.to_list()
        |> List.foldl({[Point.new()], nil}, &new_steps/2)

      points
    end

    defp new_steps({rotation, n}, {[%Point{} = p | _] = acc, face}) do
      {new_steps, face} =
        case {face, rotation} do
          {nil, :R} -> {step_n(p, {1, 0}, n), :east}
          {nil, :L} -> {step_n(p, {-1, 0}, n), :west}
          {:north, :L} -> {step_n(p, {-1, 0}, n), :west}
          {:north, :R} -> {step_n(p, {1, 0}, n), :east}
          {:south, :L} -> {step_n(p, {1, 0}, n), :east}
          {:south, :R} -> {step_n(p, {-1, 0}, n), :west}
          {:east, :L} -> {step_n(p, {0, 1}, n), :north}
          {:east, :R} -> {step_n(p, {0, -1}, n), :south}
          {:west, :L} -> {step_n(p, {0, -1}, n), :south}
          {:west, :R} -> {step_n(p, {0, 1}, n), :north}
        end

      {new_steps ++ acc, face}
    end

    defp step_n(%Point{} = p, {dx, dy}, n) do
      step_n(p, {dx, dy}, n, [])
    end

    defp step_n(%Point{}, {_, _}, 0, res) do
      res
    end

    defp step_n(%Point{} = p, {dx, dy}, n, res) do
      p = Point.new(p.x + dx, p.y + dy)
      step_n(p, {dx, dy}, n - 1, [p | res])
    end
  end

  def part_1() do
    [last_point | _] = Point.points_from_input(get_input())
    IO.inspect(last_point)

    IO.puts(Point.taxi_distance(Point.new(), last_point))
  end

  def part_2() do
    point =
      Point.points_from_input(get_input())
      |> Enum.reverse()
      |> Enum.reduce_while({MapSet.new(), nil}, fn p, {set, res} ->
        IO.inspect({p})

        case MapSet.member?(set, p) do
          true -> {:halt, p}
          false -> {:cont, {MapSet.put(set, p), res}}
        end
      end)

    IO.inspect(point)
    IO.puts(Point.taxi_distance(point))
  end
end

Day01.part_1()
Day01.part_2()
