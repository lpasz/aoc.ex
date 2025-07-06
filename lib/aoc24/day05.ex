defmodule Aoc24.Day05 do
  @moduledoc false
  import Aoc

  def part1(file_path) do
    {p1, p2} = parse(file_path)

    p2
    |> Enum.filter(fn p2 -> Enum.all?(p1, &a_smaller_than_b(&1, p2)) end)
    |> Enum.map(&get_middle/1)
    |> Enum.sum()
  end

  defp a_smaller_than_b([a, b], p2) do
    case p2 do
      %{^a => pa, ^b => pb} -> pa < pb
      _ -> true
    end
  end

  defp get_middle(map) do
    mx = map |> Map.values() |> Enum.max()

    Enum.find_value(map, fn {a, b} -> if b == ceil(mx / 2), do: a end)
  end

  defp parse(file_path) do
    {p1, p2} = two_parts_input(file_path)

    p1 = numbers_per_line(p1)

    p2 =
      p2
      |> numbers_per_line()
      |> Enum.map(&Enum.with_index(&1, 1))
      |> Enum.map(&Map.new/1)

    {p1, p2}
  end

  def part2(file_path) do
    {p1, p2} = parse(file_path)

    p2
    |> Enum.reject(fn p2 -> Enum.all?(p1, &a_smaller_than_b(&1, p2)) end)
    |> Enum.map(&to_sorted_list/1)
    |> Enum.map(&Enum.sort(&1, fn v1, v2 -> [v2, v1] not in p1 end))
    |> Enum.map(&to_sorted_map/1)
    |> Enum.map(&get_middle/1)
    |> Enum.sum()
  end

  defp to_sorted_list(map) do
    map
    |> Enum.sort_by(fn {_, idx} -> idx end)
    |> Enum.map(fn {v, _} -> v end)
  end

  defp to_sorted_map(list) do
    list
    |> Enum.with_index(1)
    |> Map.new()
  end
end
