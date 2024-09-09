defmodule Persistance.Worker do
  use Task

  @save_interval 3_000

  def start_link(_arg) do
    Task.start_link(&poll/0)
  end

  def poll() do
    receive do
    after
      @save_interval ->
        Persistance.save_database()
        poll()
    end
  end
end
