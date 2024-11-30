defmodule Helpers do
  def get_input(day) do
    file = "./input/d#{day}"

    case File.read(file) do
      {:ok, bytes} -> bytes
      {:error, err} -> throw("Unable to load #{file}: #{err}")
    end
  end
end
