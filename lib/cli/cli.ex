defmodule Cli do
  alias Cli.Handler

  def start() do
    IO.puts("Waiting for input...")
    loop()
  end

  def loop() do
    case IO.gets(">") do
      :eof ->
        "Leaving..." |> IO.puts()

      input ->
        input |> String.trim() |> Handler.handle() |> IO.puts()
        loop()
    end
  end
end
