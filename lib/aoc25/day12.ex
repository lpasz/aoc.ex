defmodule Aoc25.Day12 do
  @moduledoc false
  require Aoc

  @doc ~S"""
  ## Examples
  iex> Aoc25.Day12.part1("input.txt")
  550
  """
  def part1(file_path) do
    file_path
    |> Aoc.get_input()
    |> String.split("\n\n")
    |> List.last()
    |> String.split("\n")
    |> Enum.map(&Aoc.extract_numbers/1)
    |> Enum.map(fn [n1, n2 | nums]-> {n1 * n2, Enum.sum(nums)} end)
    |> Enum.map(fn {area, presents} -> %{true: 1, false: 0}[area >= presents * 9] end)
    |> Enum.sum()
  end
end
