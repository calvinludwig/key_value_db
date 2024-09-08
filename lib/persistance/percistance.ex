defmodule Percistance do
  def read_file(path) do
    case File.read(path) do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      _ -> nil
    end
  end

  def save_file(data, path) do
    File.write(path, :erlang.term_to_binary(data))
  end
end
