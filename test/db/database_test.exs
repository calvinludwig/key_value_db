defmodule DatabaseTest do
  use ExUnit.Case
  doctest Database

  setup_all do
    Database.load(nil)
    :ok
  end

  setup do
    Database.reset()
    :ok
  end

  test "can save a value in db" do
    Database.set("some_key", "the_value")
    value = Database.get("some_key")

    assert value == "the_value"
  end

  test "can update a value in db" do
    Database.set("some_key", "the_value")
    Database.set("some_key", "the_new_value")
    value = Database.get("some_key")

    assert value == "the_new_value"
  end

  test "start transaction and rollback" do
    Database.set("a", 1)
    Database.set("b", 2)
    Database.new_transaction()
    Database.set("b", 3)
    Database.set("c", 4)
    Database.discard_transaction()
    assert Database.get("a") == 1
    assert Database.get("b") == 2
    assert Database.get("c") == nil
  end

  test "start transaction and commit" do
    Database.set("a", 1)
    Database.set("b", 2)
    Database.new_transaction()
    Database.set("b", 3)
    Database.set("c", 4)
    Database.accept_transaction()
    assert Database.get("a") == 1
    assert Database.get("b") == 3
    assert Database.get("c") == 4
  end

  test "recursive transactions" do
    Database.set("a", 1)
    Database.new_transaction()
    Database.set("a", 2)
    assert Database.get("a") == 2
    Database.new_transaction()
    Database.set("a", 3)
    assert Database.get("a") == 3
    Database.accept_transaction()
    assert Database.get("a") == 3
    Database.discard_transaction()
    assert Database.get("a") == 1

    Database.set("b", 1)
    Database.new_transaction()
    Database.set("b", 4)
    assert Database.get("b") == 4
    Database.new_transaction()
    Database.set("b", 5)
    assert Database.get("b") == 5
    Database.accept_transaction()
    Database.accept_transaction()
    assert Database.get("b") == 5

    Database.set("c", 1)
    Database.new_transaction()
    Database.set("c", 2)
    Database.new_transaction()
    Database.set("c", 3)
    assert Database.get("c") == 3
    Database.discard_transaction()
    assert Database.get("c") == 2
    Database.accept_transaction()
    assert Database.get("c") == 2
  end
end
