defmodule Aoc25.Day02 do
  @moduledoc false
  def part1(file_path) do
    file_path
    |> parse_ids()
    |> find_invalid_ids([~r"(.+)\1"])
    |> Enum.sum()
  end

  def part2(file_path) do
    file_path
    |> parse_ids()
    |> find_invalid_ids([~r"(.+?)\1+", ~r"(.+)\1+"])
    |> Enum.sum()
  end

  defp parse_ids(file_path) do
    text = File.read!(file_path)

    ~r"(\d+)-(\d+)"
    |> Regex.scan(text)
    |> Enum.map(&tl/1)
    |> Enum.flat_map(fn [n1, n2] -> String.to_integer(n1)..String.to_integer(n2) end)
  end

  defp find_invalid_ids(ids, patterns) do
    Enum.filter(ids, fn id ->
      num = Integer.to_string(id)

      Enum.any?(patterns, fn regex ->
        case Regex.run(regex, num) do
          [^num | _rest] -> true
          _ -> false
        end
      end)
    end)
  end
end
