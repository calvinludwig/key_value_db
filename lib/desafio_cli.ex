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
    case Persistance.get_database() do
      {:ok, db} -> db |> Database.load()
      {:error, _reason} ->
        IO.puts("Unable to load stored database. Initializing a new one.")
        Database.load(nil)
    end

    setup_shutdown()
    start_persistance_worker()
    IO.puts("Waiting for your input. Press CTRL+D to exit.")
    loop()
  end

  def loop() do
    case IO.gets(">") do
      :eof ->
        :ok

      {:error, reason} ->
        IO.puts("Failed to read input: #{inspect(reason)}")
        loop()

      input ->
        input |> String.trim() |> Handler.handle() |> IO.puts()
        loop()
    end
  end

  def setup_shutdown() do
    System.trap_signal(:sigquit, fn ->
      graceful_shutdown()
      :ok
    end)

    System.trap_signal(:sigstop, fn ->
      graceful_shutdown()
      :ok
    end)

    System.at_exit(fn _status ->
      graceful_shutdown()
    end)
  end

  def graceful_shutdown() do
    Persistance.save_database()
    IO.puts("Existing...")
  end

  def start_persistance_worker() do
    opts = [strategy: :one_for_one, name: Persistance.Worker.Supervisor]
    Supervisor.start_link([Persistance.Worker], opts)
  end
end
