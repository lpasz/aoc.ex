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
    updated_matrix =
      mtx
      |> Enum.filter(fn {_point, value} -> value == "|" end)
      |> Enum.map(fn {point, _} -> point end)
      |> Enum.reduce(mtx, fn point, mtx ->
        down = Aoc.down(point)
        down_left = Aoc.left(down)
        down_right = Aoc.right(down)

        case {mtx[point], mtx[down]} do
          {"|", "."} -> Map.put(mtx, down, "|")
          {"|", "^"} -> mtx |> Map.put(down_left, "|") |> Map.put(down_right, "|")
          _else -> mtx
        end
      end)

    if updated_matrix == mtx do
      mtx
    else
      update(updated_matrix)
    end
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
    positions
    |> Enum.reduce(%{}, fn {pos, cnt}, acc ->
      next = Aoc.down(pos)

      case Map.get(mtx, next) do
        "." -> Map.update(acc, next, cnt, &(&1 + cnt))
        "^" -> acc |> Map.update(Aoc.left(next), cnt, &(&1 + cnt)) |> Map.update(Aoc.right(next), cnt, &(&1 + cnt))
        nil -> Map.update(acc, :total, cnt, &(&1 + cnt))
      end
    end)
    |> case do
      %{total: total} -> total
      acc -> bfs(mtx, acc, i + 1)
    end
  end
end
