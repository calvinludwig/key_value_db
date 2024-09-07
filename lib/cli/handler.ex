defmodule Cli.Handler do
  alias Cli.Parser

  @file_path "database"

  def get(args) do
    case Parser.parse_arguments(args, 1) do
      {:ok, [key]} ->
        value = Database.get(key)
        "Value: #{value}"

      :error ->
        "ERR \"GET <chave> - Syntax error\""
    end
  end

  def set(args) do
    case Parser.parse_arguments(args, 2) do
      {:ok, [key, value]} ->
        {updated, main_db} = Database.set(key, Parser.convert_value(value))

        if main_db do
          persist_db()
        end

        case updated do
          true -> "Replaced to #{value}"
          false -> "Setted to #{value}"
        end

      :error ->
        "ERR \"SET <chave> <valor> - Syntax error\""
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
    last_transaction = Database.accept_transaction()

    if last_transaction do
      persist_db()
    end

    show_current_transaction()
  end

  def clear_screen do
    "\e[H\e[2J"
  end

  defp persist_db() do
    Database.get_db()
    |> Percistance.save_file(@file_path)
  end

  defp show_current_transaction() do
    case Database.transactions()
         |> length() do
      0 -> "No transactions"
      n -> "Transaction level #{n}"
    end
  end
end
