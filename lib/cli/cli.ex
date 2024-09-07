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
    IO.gets(">")
    |> String.trim()
    |> handle_input()
    |> IO.puts()

    loop()
  end

  def handle_input(input) do
    {intention, args} = Parser.parse_command(input)

    case intention do
      @set -> Handler.set(args)
      @get -> Handler.get(args)
      @begin -> Handler.begin()
      @rollback -> Handler.rollback()
      @commit -> Handler.commit()
      @clear -> Handler.clear_screen()
      command -> "ERR: No command #{command}"
    end
  end
end
