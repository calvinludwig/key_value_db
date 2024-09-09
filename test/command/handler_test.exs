defmodule Command.HandlerTest do
  alias Command.Handler
  use ExUnit.Case
  doctest Command.Handler

  setup_all do
    Database.load(nil)
    :ok
  end

  setup do
    Database.reset()
    :ok
  end

  test "invalid command" do
    assert Handler.handle("TRY") == "ERR: No command TRY"
  end

  test "invalid set arguments" do
    assert Handler.handle("SET x") == "ERR \"SET <key> <value> - Syntax error\""
  end

  test "invalid get arguments" do
    assert Handler.handle("GET ") == "ERR \"GET <key> - Syntax error\""
  end

  test "set command" do
    assert Handler.handle("SET teste 1") == "FALSE 1"
    assert Handler.handle("SET teste 2") == "TRUE 2"
  end

  test "get command" do
    assert Handler.handle("GET teste") == "NIL"
    assert Handler.handle("SET teste 1") == "FALSE 1"
    assert Handler.handle("GET teste") == 1
    assert Handler.handle("SET teste 2") == "TRUE 2"
    assert Handler.handle("GET teste") == 2
  end

  test "begin command" do
    assert Handler.handle("GET teste") == "NIL"
    assert Handler.handle("BEGIN") == 1
    assert Handler.handle("SET teste 1") == "FALSE 1"
    assert Handler.handle("GET teste") == 1
  end

  test "rollback command" do
    assert Handler.handle("BEGIN") == 1
    assert Handler.handle("SET teste 1") == "FALSE 1"
    assert Handler.handle("GET teste") == 1
    assert Handler.handle("ROLLBACK") == 0
    assert Handler.handle("GET teste") == "NIL"
  end

  test "commit command" do
    assert Handler.handle("BEGIN") == 1
    assert Handler.handle("SET teste 1") == "FALSE 1"
    assert Handler.handle("GET teste") == 1
    assert Handler.handle("COMMIT") == 0
    assert Handler.handle("GET teste") == 1
  end

  test "recursive transactions" do
    assert Handler.handle("BEGIN") == 1
    assert Handler.handle("SET teste 1") == "FALSE 1"
    assert Handler.handle("GET teste") == 1
    assert Handler.handle("BEGIN") == 2
    assert Handler.handle("SET teste 2") == "FALSE 2"
    assert Handler.handle("GET teste") == 2
    assert Handler.handle("ROLLBACK") == 1
    assert Handler.handle("GET teste") == 1
    assert Handler.handle("BEGIN") == 2
    assert Handler.handle("BEGIN") == 3
    assert Handler.handle("SET teste 3") == "FALSE 3"
    assert Handler.handle("GET teste") == 3
    assert Handler.handle("COMMIT") == 2
    assert Handler.handle("GET teste") == 3
    assert Handler.handle("COMMIT") == 1
    assert Handler.handle("COMMIT") == 0
    assert Handler.handle("GET teste") == 3

    Database.reset()

    assert Handler.handle("GET teste") == "NIL"
    assert Handler.handle("BEGIN") == 1
    assert Handler.handle("SET teste 1") == "FALSE 1"
    assert Handler.handle("GET teste") == 1
    assert Handler.handle("BEGIN") == 2
    assert Handler.handle("SET foo bar") == "FALSE bar"
    assert Handler.handle("SET bar baz") == "FALSE baz"
    assert Handler.handle("GET foo ") == "bar"
    assert Handler.handle("GET bar") == "baz"
    assert Handler.handle("ROLLBACK") == 1
    assert Handler.handle("GET foo") == "NIL"
    assert Handler.handle("GET bar") == "NIL"
    assert Handler.handle("GET teste") == 1
  end

  test "nested transactions with mixed operations" do
    assert Handler.handle("BEGIN") == 1
    assert Handler.handle("SET x 1") == "FALSE 1"
    assert Handler.handle("BEGIN") == 2
    assert Handler.handle("SET x 2") == "FALSE 2"
    assert Handler.handle("SET y 3") == "FALSE 3"
    assert Handler.handle("BEGIN") == 3
    assert Handler.handle("SET x 4") == "FALSE 4"
    assert Handler.handle("ROLLBACK") == 2
    assert Handler.handle("GET x") == 2
    assert Handler.handle("GET y") == 3
    assert Handler.handle("COMMIT") == 1
    assert Handler.handle("GET x") == 2
    assert Handler.handle("GET y") == 3
    assert Handler.handle("ROLLBACK") == 0
    assert Handler.handle("GET x") == "NIL"
    assert Handler.handle("GET y") == "NIL"
  end
end
