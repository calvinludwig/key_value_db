defmodule Persistance do
  @db_path "database"

  def get_database() do
    case File.read(@db_path) do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      _ -> nil
    end
  end

  def save_database() do
    File.write(@db_path, :erlang.term_to_binary(Database.get_db()))
  end
end
