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
end
