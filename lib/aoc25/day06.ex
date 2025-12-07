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
    |> Enum.map(fn line ->
      case Aoc.extract_positive_numbers(line) do
        [] -> ~r/\*|\+/ |> Regex.scan(line) |> List.flatten()
        numbers -> numbers
      end
    end)
    |> Aoc.transpose()
    |> Enum.map(fn line ->
      Enum.reduce(line, [], fn num, acc ->
        cond do
          is_number(num) -> [num | acc]
          "*" == num -> Enum.product(acc)
          "+" == num -> Enum.sum(acc)
        end
      end)
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
    |> String.split("\n")
    |> Enum.reject(&(String.trim(&1) == ""))
    |> Enum.map(&String.codepoints/1)
    |> Enum.map(&Enum.reverse/1)
    |> Aoc.transpose()
    |> Enum.map(&Enum.join/1)
    |> Enum.reduce({0, []}, fn itm, {acc, mid} ->
      case Regex.scan(~r/\d+|\+|\*/, itm) do
        [] -> {acc, mid}
        [[num]] -> {acc, [String.to_integer(num) | mid]}
        [[num], ["+"]] -> {acc + Enum.sum([String.to_integer(num) | mid]), []}
        [[num], ["*"]] -> {acc + Enum.product([String.to_integer(num) | mid]), []}
      end
    end)
    |> then(fn {acc, _} -> acc end)
  end
end
