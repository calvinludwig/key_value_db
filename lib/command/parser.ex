defmodule Command.Parser do
  def parse_command(input) do
    case String.split(input, " ", parts: 2) do
      [intention, arguments] -> {intention, arguments}
      [intention] -> {intention, ""}
      _ -> {"", ""}
    end
  end

  @regex ~r/(?:[^\s"]|"(?:\\.|[^"\\])*")+/u
  def parse_arguments(string, number_of_arguments) do
    arguments =
      Regex.scan(@regex, string)
      |> Enum.map(&List.first/1)

    if length(arguments) == number_of_arguments do
      {:ok, arguments}
    else
      :error
    end
  end

  def convert_value("TRUE"), do: true
  def convert_value("FALSE"), do: false

  def convert_value(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> remove_quotes(value)
    end
  end

  defp remove_quotes(segment) do
    if String.starts_with?(segment, "\"") && String.ends_with?(segment, "\"") do
      segment |> String.slice(1..-2//1) |> String.replace(~r/\\"/, "\"")
    else
      segment
      |> String.replace(~r/\\"/, "\"")
    end
  end
end
