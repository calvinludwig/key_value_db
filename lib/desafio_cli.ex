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
    Persistance.get_database()
    |> Database.load()
    start_persistance_worker()
    IO.puts("Waiting for input...")
    loop()
  end

  def loop() do
    case IO.gets(">") do
      :eof ->
        Persistance.save_database()
        "Leaving..." |> IO.puts()

      {:error, reason} ->
        IO.puts("Failed to read input: #{inspect(reason)}")
        loop()

      input ->
        input |> String.trim() |> Handler.handle() |> IO.puts()
        loop()
    end
  end

  def start_persistance_worker() do
    opts = [strategy: :one_for_one, name: Persistance.Worker.Supervisor]
    Supervisor.start_link([Persistance.Worker], opts)
  end
end
