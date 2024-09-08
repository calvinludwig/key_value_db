defmodule DatabaseTest do
  use ExUnit.Case
  doctest Database

  test "can save a value in db" do
    Database.load(nil)
    Database.set("some_key", "the_value")
    value = Database.get("some_key")

    assert value == "the_value"
  end

  test "can update a value in db" do
    Database.load(nil)
    Database.set("some_key", "the_value")
    Database.set("some_key", "the_new_value")
    value = Database.get("some_key")

    assert value == "the_new_value"
  end

  test "if key does not exist, it returns nil" do
    Database.load(nil)
    value = Database.get("some_key")
    assert value == "NIL"
  end
end
