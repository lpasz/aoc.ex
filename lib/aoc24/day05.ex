defmodule Aoc24.Day05 do
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

    Enum.find_value(map, fn {a, b} ->
      if b == ceil(mx / 2) do
        a
      end
    end)
  end

  defp parse(file_path) do
    {p1, p2} = two_parts_input(file_path)

    p1 = numbers_per_line(p1)
    p2 = p2 |> numbers_per_line() |> Enum.map(&Enum.with_index(&1, 1)) |> Enum.map(&Map.new/1)

    {p1, p2}
  end

  def part2(file_path) do
    {p1, p2} = parse(file_path)

    made_valid =
      p2
      |> Enum.reject(fn p2 -> Enum.all?(p1, &a_smaller_than_b(&1, p2)) end)
      |> Enum.map(fn list ->
        list
        |> Enum.sort_by(fn {_, idx} -> idx end)
        |> Enum.map(fn {v, _} -> v end)
        |> Enum.sort(fn v1, v2 ->
          cond do
            [v2, v1] in p1 -> false
            [v1, v2] in p1 -> true
            :else -> true
          end
        end)
        |> Enum.with_index(1)
        |> Map.new()
      end)
      |> Enum.map(&get_middle/1)
      |> Enum.sum()

    made_valid
  end
end
