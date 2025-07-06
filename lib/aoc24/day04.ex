defmodule Aoc24.Day04 do
  @moduledoc false
  import Aoc

  def part1(file_path) do
    mtx = read_matrix_map(file_path)

    mtx
    |> Map.keys()
    |> Enum.flat_map(fn {x, y} -> {x, y} |> xmas() |> Enum.map(&mtx_string(&1, mtx)) end)
    |> Enum.count(&(&1 in ["XMAS", "SAMX"]))
  end

  defp mtx_string(positions, mtx) do
    Enum.map_join(positions, &mtx[&1])
  end

  defp xmas({x, y}) do
    [
      # ➡️ 
      [{x, y}, {x + 1, y}, {x + 2, y}, {x + 3, y}],
      # ⬇️
      [{x, y}, {x, y + 1}, {x, y + 2}, {x, y + 3}],
      # ↘️
      [{x, y}, {x + 1, y + 1}, {x + 2, y + 2}, {x + 3, y + 3}],
      # ↙️
      [{x, y}, {x - 1, y + 1}, {x - 2, y + 2}, {x - 3, y + 3}]
    ]
  end

  def part2(file_path) do
    mtx = read_matrix_map(file_path)

    mtx
    |> Map.keys()
    |> Enum.count(fn {x, y} ->
      {x, y} |> x_mas() |> Enum.map(&mtx_string(&1, mtx)) |> Enum.all?(&(&1 in ["MAS", "SAM"]))
    end)
  end

  defp x_mas({x, y}) do
    [
      # ↖️⏺️↘️
      [{x - 1, y - 1}, {x, y}, {x + 1, y + 1}],
      # ↙️⏺️↗️
      [{x - 1, y + 1}, {x, y}, {x + 1, y - 1}]
    ]
  end
end
