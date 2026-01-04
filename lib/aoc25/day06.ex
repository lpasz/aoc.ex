defmodule Aoc25.Day06 do
  @moduledoc "https://adventofcode.com/2025/day/6"

  require Aoc

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day06.part1("example.txt")
    4277556
    iex> Aoc25.Day06.part1("input.txt")
    6417439773370
  """
  def part1(file_path) do
    file_path
    |> Aoc.get_input()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Aoc.transpose()
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(fn [h | t] -> [h | Enum.map(t, &String.to_integer/1)] end)
    |> Enum.map(fn
      ["*" | numbers] -> Enum.product(numbers)
      ["+" | numbers] -> Enum.sum(numbers)
    end)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day06.part2("example.txt")
    3263827
    iex> Aoc25.Day06.part2("input.txt")
    11044319475191
  """
  def part2(file_path) do
    file_path
    |> Aoc.get_input()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.codepoints/1)
    |> Aoc.transpose()
    |> Enum.flat_map(&parse_int/1)
    |> Enum.chunk_by(&is_binary/1)
    |> Enum.chunk_every(2)
    |> Enum.map(fn
      [["*"], rest] -> Enum.product(rest)
      [["+"], rest] -> Enum.sum(rest)
    end)
    |> Enum.sum()
  end

  defp parse_int(codepoints) do
    s = codepoints |> Enum.reject(&(&1 in ["", " "])) |> Enum.join()
    lst = String.last(s)
    parsed = Integer.parse(s)

    cond do
      :error == parsed -> []
      lst in ["*", "+"] -> [lst, elem(parsed, 0)]
      :else -> [elem(parsed, 0)]
    end
  end
end
