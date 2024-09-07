defmodule Cli.Parser do
  def parse_command(string) do
    string
    |> String.split(" ", parts: 2)
    |> case do
      [intention, arguments] -> {intention |> String.upcase(), arguments}
      [intention] -> {intention |> String.upcase(), ""}
      _ -> {"", ""}
    end
  end

  def parse_arguments(string, number_of_arguments) do
    regex = ~r/(?:[^\s"]|"(?:\\.|[^"\\])*")+/u

    case {
      number_of_arguments,
      Regex.scan(regex, string)
      |> Enum.map(&List.first/1)
    } do
      {2, [v1, v2]} -> {:ok, [v1, v2]}
      {1, [v1]} -> {:ok, [v1]}
      _ -> :error
    end
  end

  def convert_value(value) do
    case value do
      "TRUE" ->
        true

      "FALSE" ->
        false

      _ ->
        case Integer.parse(value) do
          {int, _} -> int
          _ -> remove_quotes(value)
        end
    end
  end

  def remove_quotes(segment) do
    if String.starts_with?(segment, "\"") and String.ends_with?(segment, "\"") do
      segment
      # Remove the surrounding quotes
      |> String.slice(1..-2//1)
      # Replace escaped quotes with real quotes
      |> String.replace(~r/\\"/, "\"")
    else
      segment
    end
  end
end
