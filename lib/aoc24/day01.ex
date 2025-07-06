defmodule Aoc24.Day01 do
  @moduledoc false
  def part1(file_path) do
    file_path
    |> Aoc.read_matrix(&String.to_integer/1)
    |> Aoc.transpose()
    |> Enum.map(&Enum.sort/1)
    |> Aoc.transpose()
    |> Enum.map(fn [a, b] -> abs(a - b) end)
    |> Enum.sum()
  end

  def part2(file_path) do
    file_path
    |> Aoc.read_matrix(&String.to_integer/1)
    |> Aoc.transpose()
    |> then(fn [list1, list2] ->
      list1
      |> Enum.map(fn a -> a * Enum.count(list2, &(&1 == a)) end)
      |> Enum.sum()
    end)
  end
end
