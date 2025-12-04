defmodule Aoc25.Day04 do
  @moduledoc false
  def part1(file_path) do
    matrix = Aoc.read_matrix_map(file_path)
    fork_liftable = fork_liftable(matrix)
    Enum.count(fork_liftable)
  end

  def part2(file_path) do
    matrix = Aoc.read_matrix_map(file_path)
    fork_lift_until(matrix)
  end

  defp fork_lift_until(matrix, acc \\ 0) do
    case fork_liftable(matrix) do
      [] ->
        acc

      fork_liftable ->
        lifted = Enum.count(fork_liftable)

        matrix
        |> lift(fork_liftable)
        |> fork_lift_until(acc + lifted)
    end
  end

  defp lift(matrix, to_lift) do
    Enum.reduce(to_lift, matrix, fn {coord, "@"}, acc ->
      Map.put(acc, coord, ".")
    end)
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
    |> Enum.filter(&(&1 == "@"))
    |> then(fn cnt -> Enum.count(cnt) < 4 end)
  end
end
