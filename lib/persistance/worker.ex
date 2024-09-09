defmodule Persistance.Worker do
  use Task

  def start_link(_arg) do
    Task.start_link(&poll/0)
  end

  def poll() do
    receive do
    after
      3_000 ->
        Persistance.save_database()
        poll()
    end
  end
end
