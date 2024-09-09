defmodule Command.ParserTest do
  alias Command.Parser
  use ExUnit.Case
  doctest Command.Parser

  test "parse command" do
    command = "SET a b"
    assert Parser.parse_command(command) == {"SET", "a b"}
  end

  test "parse integer arguments" do
    arguments = "1"
    assert Parser.parse_arguments(arguments, 1) == {:ok, ["1"]}
  end

  test "parse one arguments" do
    arguments = "arg1"
    assert Parser.parse_arguments(arguments, 1) == {:ok, ["arg1"]}
  end

  test "parse two arguments" do
    arguments = "arg1 arg2"
    assert Parser.parse_arguments(arguments, 2) == {:ok, ["arg1", "arg2"]}
  end

  test "parse arguments with double quotes" do
    arguments = "\"some frase\""
    assert Parser.parse_arguments(arguments, 1) == {:ok, ["\"some frase\""]}

    arguments = "\"some frase\" arg2"
    assert Parser.parse_arguments(arguments, 2) == {:ok, ["\"some frase\"", "arg2"]}

    arguments = "\"some frase\" \"other frase\""
    assert Parser.parse_arguments(arguments, 2) == {:ok, ["\"some frase\"", "\"other frase\""]}
  end

  test "parse arguments with double quotes and a escaped double quote" do
    arguments = "\"another\\\" frase\""
    assert Parser.parse_arguments(arguments, 1) == {:ok, ["\"another\\\" frase\""]}

    arguments = "\"a different\\\" frase\" arg2"
    assert Parser.parse_arguments(arguments, 2) == {:ok, ["\"a different\\\" frase\"", "arg2"]}

    arguments = "\"a different\\\" frase\" \"other frase\""

    assert Parser.parse_arguments(arguments, 2) ==
             {:ok, ["\"a different\\\" frase\"", "\"other frase\""]}

    arguments = "\"a different\\\" frase\" \"other \\\" frase\""

    assert Parser.parse_arguments(arguments, 2) ==
             {:ok, ["\"a different\\\" frase\"", "\"other \\\" frase\""]}

    arguments = "\"a different frase\" \"other \\\" frase\""

    assert Parser.parse_arguments(arguments, 2) ==
             {:ok, ["\"a different frase\"", "\"other \\\" frase\""]}
  end
end
