defmodule Command.Handler do
  alias Command.Parser

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

  def get(args) do
    with {:ok, [key]} <- Parser.parse_arguments(args, 1),
         value <- Database.get(key) do
      case value do
        nil -> "NIL"
        _ -> value
      end
    else
      :error -> "ERR \"GET <key> - Syntax error\""
    end
  end

  def set(args) do
    with {:ok, [key, value]} <- Parser.parse_arguments(args, 2),
         {operation, _} <- Database.set(key, Parser.convert_value(value)) do
      case operation do
        :updated -> "TRUE #{value}"
        :created -> "FALSE #{value}"
      end
    else
      :error -> "ERR \"SET <key> <value> - Syntax error\""
    end
  end

  def begin() do
    Database.new_transaction()
    show_current_transaction()
  end

  def rollback() do
    case Database.discard_transaction() do
      :no_transaction -> "ERR: No transactions to rollback"
      _ -> show_current_transaction()
    end
  end

  def commit() do
    case Database.accept_transaction() do
      :no_transaction -> "ERR: No transactions to commit"
      _ -> show_current_transaction()
    end
  end

  def clear_screen do
    "\e[H\e[2J"
  end

  defp show_current_transaction() do
    Database.transactions()
    |> length()
  end
end
