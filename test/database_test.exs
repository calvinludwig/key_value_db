defmodule DesafioCliTest do
  use ExUnit.Case
  doctest DesafioCli

  test "can save a value in db" do
    {:ok, db} = Database.load()
    Database.set(db, "some_key", "the_value")
    value = Database.get(db, "some_key")

    assert value == "the_value"
  end

  test "can update a value in db" do
    {:ok, db} = Database.load()
    Database.set(db, "some_key", "the_value")
    Database.set(db, "some_key", "the_new_value")
    value = Database.get(db, "some_key")

    assert value == "the_new_value"
  end
end
