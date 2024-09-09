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
    case Parser.parse_arguments(args, 1) do
      {:ok, [key]} ->
        value = Database.get(key)

        case value do
          nil -> "Value: NIL"
          _ -> "Value: #{value}"
        end

      :error ->
        "ERR \"GET <chave> - Syntax error\""
    end
  end

  def set(args) do
    case Parser.parse_arguments(args, 2) do
      {:ok, [key, value]} ->
        {operation, _} = Database.set(key, Parser.convert_value(value))

        case operation do
          :updated -> "Replaced to #{value}"
          :created -> "Setted to #{value}"
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
    case Database.accept_transaction() do
      :no_transaction ->
        "ERR: No transactions to commit"

      true ->
        show_current_transaction()

      false ->
        show_current_transaction()
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
