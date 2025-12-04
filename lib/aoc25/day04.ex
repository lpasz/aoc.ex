defmodule Aoc25.Day04 do
  @moduledoc false
  def part1(file_path) do
    file_path
    |> Aoc.read_matrix_map()
    |> fork_liftable()
    |> Enum.count()
  end

  def part2(file_path) do
    file_path
    |> Aoc.read_matrix_map()
    |> fork_lift_until_unable(lifted_so_far: 0)
  end

  defp fork_lift_until_unable(matrix, lifted_so_far: acc) do
    fork_liftable = fork_liftable(matrix)

    if Enum.empty?(fork_liftable) do
      acc
    else
      lifted_so_far = acc + length(fork_liftable)

      matrix
      |> lift(fork_liftable)
      |> fork_lift_until_unable(lifted_so_far: lifted_so_far)
    end
  end

  defp lift(matrix, to_lift) do
    Enum.reduce(to_lift, matrix, fn {coord, "@"}, acc -> Map.put(acc, coord, ".") end)
  end

  defp fork_liftable(matrix) do
    matrix
    |> Enum.filter(fn {_coord, val} -> val == "@" end)
    |> Enum.filter(&fork_liftable?(&1, matrix))
  end

  defp fork_liftable?({coord, "@"}, matrix) do
    coord
    |> Aoc.around()
    |> Enum.map(&Map.get(matrix, &1))
    |> Enum.count(&(&1 == "@"))
    |> Kernel.<(4)
  end
end
