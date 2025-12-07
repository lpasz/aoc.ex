defmodule Aoc25.Day05 do
  @moduledoc "https://adventofcode.com/2025/day/5"

  require Aoc

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day05.part1("example.txt")
    3
    iex> Aoc25.Day05.part1("input.txt")
    733
  """
  def part1(file_path) do
    {fresh_ingredient_ids, ingredient_ids} = parse(file_path)
    Enum.count(ingredient_ids, fn ingredient_id -> Enum.any?(fresh_ingredient_ids, &(ingredient_id in &1)) end)
  end

  @doc ~S"""
  ## Examples
    # iex> Aoc25.Day05.part2("example.txt")
    # 14
    iex> Aoc25.Day05.part2("input.txt")
    345821388687084
  """
  def part2(file_path) do
    {fresh_ingredient_ids, _ingredient_ids} = parse(file_path)

    fresh_ingredient_ids
    |> Enum.reduce([], fn
      range, [] ->
        [range]

      range1, [range2 | rest] ->
        if range1.first in range2 do
          range = min(range1.first, range2.first)..max(range1.last, range2.last)
          [range | rest]
        else
          [range1, range2 | rest]
        end
    end)
    |> Enum.map(&Range.size/1)
    |> Enum.sum()
  end

  defp parse(file_path) do
    [fresh_ingredient_ids, ingredient_ids] =
      file_path |> Aoc.get_input() |> String.split("\n\n", trim: true)

    fresh_ingredient_ids =
      fresh_ingredient_ids
      |> Aoc.extract_positive_numbers()
      |> Enum.chunk_every(2)
      |> Enum.map(&Enum.sort/1)
      |> Enum.map(fn [n1, n2] -> n1..n2 end)
      |> Enum.sort()

    {fresh_ingredient_ids, Aoc.extract_positive_numbers(ingredient_ids)}
  end
end
