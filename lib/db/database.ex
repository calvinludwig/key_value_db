defmodule Database do
  def load(db) do
    initial_state = if is_nil(db), do: %{}, else: db
    Agent.start_link(fn -> initial_state end, name: :main_db)
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
        if Enum.empty?(rest) do
          Agent.update(:main_db, &Map.merge(&1, current_transaction))
          Agent.update(:transactions, fn _ -> [] end)
          true
        else
          Agent.update(:transactions, fn [_ | rest] ->
            [Map.merge(hd(rest), current_transaction) | tl(rest)]
          end)

          false
        end
    end
  end

  def set(key, value) do
    case transactions() do
      [] ->
        update_result =
          Agent.get_and_update(:main_db, fn state ->
            {(Map.has_key?(state, key) && :updated) || :created, Map.put(state, key, value)}
          end)

        {update_result, true}

      _ ->
        update_result =
          Agent.get_and_update(:transactions, fn [current | rest] ->
            {(Map.has_key?(current, key) && :updated) || :created,
             [Map.put(current, key, value) | rest]}
          end)

        {update_result, false}
    end
  end

  def get(key) do
    get_in_transactions(key) || get_in_main_db(key)
  end

  defp get_in_transactions(key) do
    transactions()
    |> Enum.find_value(&Map.get(&1, key))
  end

  defp get_in_main_db(key) do
    Agent.get(:main_db, &Map.get(&1, key))
  end

  def get_db, do: Agent.get(:main_db, & &1)

  def transactions, do: Agent.get(:transactions, & &1)

  def reset() do
    Agent.update(:main_db, fn _ -> %{} end)
    Agent.update(:transactions, fn _ -> [] end)
  end
end
