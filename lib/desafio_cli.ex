defmodule DesafioCli do
  alias Command.Handler

  @moduledoc """
  Ponto de entrada para a CLI.
  """

  @doc """
  A função main recebe os argumentos passados na linha de
  comando como lista de strings e executa a CLI.
  """
  def main(_args) do
    stored_db = Percistance.read_file("database")

    {:ok, _} = Database.load(stored_db)

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
