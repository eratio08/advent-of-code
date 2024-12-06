defmodule M2 do
  def new(ls) do
    ls
    |> Enum.reduce({}, fn l, t ->
      Tuple.append(t, l |> Enum.reduce({}, fn v, t -> Tuple.append(t, v) end))
    end)
  end

  def height(m) do
    tuple_size(m)
  end

  def width(m) do
    tuple_size(elem(m, 0))
  end

  def get!(m, x, y) do
    m |> elem(y) |> elem(x)
  end

  def put!(m, x, y, value) do
    xa = elem(m, y)
    put_elem(m, y, put_elem(xa, x, value))
  end

  def reduce(m, acc, fun) do
    Enum.reduce(0..(height(m) - 1), acc, fn y, acc ->
      Enum.reduce(0..(width(m) - 1), acc, fn x, acc ->
        fun.(get!(m, x, y), acc)
      end)
    end)
  end

  def map(m, fun) do
    Enum.reduce(0..(height(m) - 1), m, fn y, m ->
      Enum.reduce(0..(width(elem(m, 0)) - 1), m, fn x, m ->
        put!(m, x, y, fun.(get!(m, x, y)))
      end)
    end)
  end

  def as_list(m) do
    reduce(m, [], fn i, acc -> [i | acc] end) |> Enum.reverse()
  end
end
