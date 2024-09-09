defmodule Database do
  def load(db) do
    initial_state = fn ->
      case db do
        nil -> %{}
        _ -> db
      end
    end

    Agent.start_link(initial_state, name: :main_db)
    Agent.start_link(fn -> [] end, name: :transactions)
  end

  def new_transaction() do
    Agent.update(:transactions, fn state -> [%{} | state] end)
  end

  def discard_transaction() do
    Agent.update(:transactions, fn state -> List.delete_at(state, 0) end)
  end

  def accept_transaction() do
    case transactions() do
      [] ->
        :no_transaction

      [current_transaction | rest] ->
        case rest do
          [] ->
            Agent.update(:main_db, fn state -> Map.merge(state, current_transaction) end)
            Agent.update(:transactions, fn _ -> [] end)
            true

          [next | rest] ->
            Agent.update(:transactions, fn _ -> [Map.merge(next, current_transaction) | rest] end)
            false
        end
    end
  end

  def set(key, value) do
    case transactions() do
      [] ->
        {
          Agent.get_and_update(:main_db, fn state ->
            case Map.get(state, key) do
              nil -> {:created, Map.put(state, key, value)}
              _ -> {:updated, Map.put(state, key, value)}
            end
          end),
          true
        }

      [current_transaction | rest] ->
        {
          Agent.get_and_update(:transactions, fn _ ->
            current_transaction = Map.put(current_transaction, key, value)

            case Map.get(current_transaction, key) do
              nil -> {:created, [current_transaction | rest]}
              _ -> {:updated, [current_transaction | rest]}
            end
          end),
          false
        }
    end
  end

  def get(key) do
    case get_in_transactions(key) do
      nil -> get_in_main_db(key)
      value -> value
    end
  end

  defp get_in_transactions(key) do
    Enum.find_value(transactions(), fn map -> Map.get(map, key) end)
  end

  defp get_in_main_db(key) do
    Agent.get(:main_db, fn state -> Map.get(state, key) end)
  end

  @spec get_db() :: map()
  def get_db() do
    Agent.get(:main_db, fn s -> s end)
  end

  @spec transactions() :: list()
  def transactions do
    Agent.get(:transactions, fn s -> s end)
  end
end
