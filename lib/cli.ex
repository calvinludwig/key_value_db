defmodule Cli do
  def start() do
    IO.puts("Waiting for input...")
    {:ok, _} = Database.load()
    loop()
  end

  def loop() do
    IO.gets(">")
    |> String.trim()
    |> handle_input()

    loop()
  end

  def handle_input(input) do
    {intention, args} = Command.parse(input)

    case intention do
      "SET" -> Handler.set(args)
      "GET" -> Handler.get(args)
      "BEGIN" -> Handler.begin()
      "ROLLBACK" -> Handler.rollback()
      "COMMIT" -> Handler.commit()
      "CLEAR" -> clear_screen()
      command -> IO.puts("ERR: No command #{command}")
    end
  end

  defp clear_screen do
    IO.puts("\e[H\e[2J")
  end
end
