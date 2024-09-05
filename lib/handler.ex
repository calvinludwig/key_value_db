defmodule Handler do
  def get(args) do
    case Command.parse_arguments(args, 1) do
      {:ok, [key]} ->
        value = Database.get(key)
        IO.puts("Value: #{value}")

      :error ->
        IO.puts("ERR \"GET <chave> - Syntax error\"")
    end
  end

  def set(args) do
    case Command.parse_arguments(args, 2) do
      {:ok, [key, value]} ->
        case Database.set(key, Command.convert_value(value)) do
          true ->
            IO.puts("Replaced to #{value}")

          false ->
            IO.puts("Setted to #{value}")
        end

        Database.persist()

      :error ->
        IO.puts("ERR \"SET <chave> <valor> - Syntax error\"")
    end
  end

  def begin() do
    Database.new_transaction()
    show_current_transaction()
  end

  def rollback() do
    Database.discard_transaction()
    show_current_transaction()
  end

  def commit() do
    Database.accept_transaction()

    if Database.transactions() |> length() == 0 do
      Database.persist()
    end

    show_current_transaction()
  end

  defp show_current_transaction() do
    case Database.transactions()
         |> length() do
      0 -> IO.puts("No transactions")
      n -> IO.puts("Transaction level #{n}")
    end
  end
end
