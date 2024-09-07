defmodule DesafioCli do
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
    Cli.start()
  end
end
