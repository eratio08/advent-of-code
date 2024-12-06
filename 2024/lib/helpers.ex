defmodule Helpers do
  def get_input(day) do
    file = "./input/d#{day}"

    case File.read(file) do
      {:ok, bytes} -> bytes
      {:error, err} -> throw("Unable to load #{file}: #{err}")
    end
  end

  def get_lines(day) do
    get_input(day) |> String.split("\n", trim: true)
  end

  def get_matrix(day) do
    get_lines(day) |> Enum.map(fn l -> String.split(l, "", trim: true) end)
  end

  def get_lines_strm(day) do
    File.stream!("./input/d#{day}", :line)
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  def get_m2(day) do
    get_lines_strm(day)
    |> Stream.map(&String.split(&1, "", trim: true))
    |> Stream.map(fn l -> Enum.reduce(l, {}, &Tuple.append(&2, &1)) end)
    |> Enum.reduce({}, &Tuple.append(&2, &1))
  end
end
