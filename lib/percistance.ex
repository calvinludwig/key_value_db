defmodule Percistance do
  def read_file(path) do
    case File.read(path) do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      _ -> nil
    end
  end

  def save_file(data, path) do
    :erlang.term_to_binary(data)
    |> File.write(path)
  end
end
