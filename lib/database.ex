defmodule Database do
  def load() do
    Agent.start_link(fn -> %{} end)
  end

  def get(db, key) do
    Agent.get(db, &Map.get(&1, key))
  end

  def set(db, key, value) do
    Agent.update(db, &Map.put(&1, key, value))
  end
end
