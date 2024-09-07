defmodule Cli do
  alias Cli.Parser
  alias Cli.Handler

  @set "SET"
  @get "GET"
  @begin "BEGIN"
  @rollback "ROLLBACK"
  @commit "COMMIT"
  @clear "CLEAR"

  def start() do
    IO.puts("Waiting for input...")
    loop()
  end

  def loop() do
    case IO.gets(">") do
      :eof -> :ok
      input -> input |> String.trim() |> handle_input() |> IO.puts()
      loop()
    end
  end

  def handle_input(input) do
    case Parser.parse_command(input) do
      {@set, args} -> Handler.set(args)
      {@get, args} -> Handler.get(args)
      {@begin, _} -> Handler.begin()
      {@rollback, _} -> Handler.rollback()
      {@commit, _} -> Handler.commit()
      {@clear, _} -> Handler.clear_screen()
      {command, _} -> "ERR: No command #{command}"
    end
  end
end
