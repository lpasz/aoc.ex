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
    |> String.split("\n")
    |> Enum.filter(&String.contains?(&1, "x"))
    |> Enum.map(&Aoc.extract_numbers/1)
    |> Aoc.keep(fn [n1, n2 | nums] ->
      area = n1 * n2
      presents = Enum.sum(nums)

      if area >= presents * 9 do
        1
      end
    end)
    |> Enum.sum()
  end
end
