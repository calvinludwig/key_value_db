defmodule Command.Handler do
  alias Command.Parser

  @file_path "database"

  @set "SET"
  @get "GET"
  @begin "BEGIN"
  @rollback "ROLLBACK"
  @commit "COMMIT"
  @clear "CLEAR"

  def handle(input) do
    case Parser.parse_command(input) do
      {@set, args} -> set(args)
      {@get, args} -> get(args)
      {@begin, _} -> begin()
      {@rollback, _} -> rollback()
      {@commit, _} -> commit()
      {@clear, _} -> clear_screen()
      {command, _} -> "ERR: No command #{command}"
    end
  end

  @spec get(binary()) :: <<_::56, _::_*8>>
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
