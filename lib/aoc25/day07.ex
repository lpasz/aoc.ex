defmodule Aoc25.Day07 do
  @moduledoc "https://adventofcode.com/2025/day/7"

  require Aoc

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day07.part1("example.txt")
    21
    iex> Aoc25.Day07.part1("input.txt")
    1507
  """
  def part1(file_path) do
    mtx = parse(file_path)
    s = Enum.find_value(mtx, fn {point, value} -> if value == "S", do: point end)
    mtx = Map.put(mtx, Aoc.down(s), "|")
    mtx = update(mtx)

    Enum.count(mtx, fn {point, value} ->
      dir_fns = [&Aoc.up/1, &Aoc.right/1, &Aoc.left/1]
      value == "^" and Enum.all?(dir_fns, &(Map.get(mtx, &1.(point)) == "|"))
    end)
  end

  defp update(mtx) do
    mtx
    |> Aoc.keep(fn {k, v} -> if v == "|", do: k end)
    |> Enum.reduce(mtx, fn point, mtx ->
      down = Aoc.down(point)

      case {Map.get(mtx, point), Map.get(mtx, down)} do
        {"|", "."} -> Map.put(mtx, down, "|")
        {"|", "^"} -> mtx |> Map.put(Aoc.left(down), "|") |> Map.put(Aoc.right(down), "|")
        _else -> mtx
      end
    end)
    |> then(
      &if &1 == mtx do
        mtx
      else
        update(&1)
      end
    )
  end

  defp parse(input) do
    input |> Aoc.get_input() |> Aoc.parse_matrix_map()
  end

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day07.part2("example.txt")
    40
    iex> Aoc25.Day07.part2("input.txt")
    1537373473728
  """
  def part2(file_path) do
    mtx = parse(file_path)
    s = Enum.find_value(mtx, fn {point, value} -> if value == "S", do: point end)
    bfs(mtx, %{Aoc.down(s) => 1})
  end

  defp bfs(mtx, positions, i \\ 1) do
    positions =
      Enum.reduce(positions, %{}, fn {pos, cnt}, acc ->
        next = Aoc.down(pos)

        case Map.get(mtx, next) do
          "." -> Map.update(acc, next, cnt, &(&1 + cnt))
          "^" -> acc |> Map.update(Aoc.left(next), cnt, &(&1 + cnt)) |> Map.update(Aoc.right(next), cnt, &(&1 + cnt))
          nil -> Map.update(acc, :total, cnt, &(&1 + cnt))
        end
      end)

    if total = Map.get(positions, :total) do
      total
    else
      bfs(mtx, positions, i + 1)
    end
  end
end
