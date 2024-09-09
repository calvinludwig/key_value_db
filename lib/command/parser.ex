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
      {int, _} -> int
      _ -> remove_quotes(value)
    end
  end

  defp remove_quotes(segment) do
    segment
    |> String.trim(~s("))
    |> String.replace(~r/\\"/, "\"")
  end
end
