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
    reduce_pos(m, acc, fn _, v -> fun.(v) end)
  end

  def reduce_pos(m, acc, fun) do
    y_r = 0..(height(m) - 1)
    x_r = 0..(width(m) - 1)

    Enum.reduce(y_r, acc, fn y, acc ->
      Enum.reduce(x_r, acc, fn x, acc ->
        fun.({x, y}, get!(m, x, y), acc)
      end)
    end)
  end

  def map(m, fun) do
    map_pos(m, fn _, v -> fun.(v) end)
  end

  def map_pos(m, fun) do
    y_r = 0..(height(m) - 1)
    x_r = 0..(width(m) - 1)

    Enum.reduce(y_r, m, fn y, m ->
      Enum.reduce(x_r, m, fn x, m ->
        put!(m, x, y, fun.({x, y}, get!(m, x, y)))
      end)
    end)
  end

  def as_list(m) do
    reduce(m, [], fn i, acc -> [i | acc] end) |> Enum.reverse()
  end
end
