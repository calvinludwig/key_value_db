defmodule Database do
  def load(db) do
    Agent.start_link(
      fn ->
        case db do
          nil -> %{}
          db -> db
        end
      end,
      name: :main_db
    )

    Agent.start_link(fn -> [] end, name: :transactions)
  end

  def new_transaction() do
    Agent.update(:transactions, &[%{} | &1])
  end

  def discard_transaction() do
    Agent.update(:transactions, &List.delete_at(&1, 0))
  end

  def accept_transaction() do
    t = transactions()

    case t |> length() do
      0 ->
        IO.puts("ERR: No transactions to commit")

      _ ->
        {cur, t} = List.pop_at(t, 0)

        case List.first(t) do
          nil ->
            Agent.update(:main_db, &Map.merge(&1, cur))
            Agent.update(:transactions, &(&1 |> List.delete_at(0)))
            true

          next ->
            Agent.update(
              :transactions,
              &(&1 |> List.delete_at(0) |> List.replace_at(0, Map.merge(next, cur)))
            )

            false
        end
    end
  end

  def set(key, value) do
    t = transactions()

    case t |> length() do
      0 ->
        updated =
          case Agent.get(:main_db, &Map.get(&1, key)) do
            nil -> false
            _ -> true
          end

        Agent.update(:main_db, &Map.put(&1, key, value))
        {updated, true}

      _ ->
        first = List.first(t)
        updated = first |> Map.has_key?(key)
        Agent.update(:transactions, &(&1 |> List.replace_at(0, first |> Map.put(key, value))))
        {updated, false}
    end
  end

  def get(key) do
    case transactions() |> Enum.find(fn map -> Map.has_key?(map, key) end) do
      nil ->
        case Agent.get(:main_db, &Map.get(&1, key)) do
          nil -> "NIL"
          val -> val
        end

      transaction ->
        transaction |> Map.get(key)
    end
  end

  def get_db() do
    Agent.get(:main_db, & &1)
  end

  def transactions do
    Agent.get(:transactions, & &1)
  end

  def current_transaction do
    transactions() |> List.first()
  end
end
