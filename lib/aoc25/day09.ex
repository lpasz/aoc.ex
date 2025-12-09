defmodule Aoc25.Day09 do
  @moduledoc "https://adventofcode.com/2025/day/9"

  require Aoc

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day09.part1("example.txt")
    50
    iex> Aoc25.Day09.part1("input.txt")
    4746238001
  """
  def part1(file_path) do
    {_points, area} =
      file_path
      |> Aoc.get_input()
      |> Aoc.extract_numbers()
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)
      |> areas()
      |> Enum.max_by(&elem(&1, 1))

    area
  end

  defp areas(list, acc \\ []) do
    case list do
      [point | rest_points] ->
        acc =
          acc ++
            Enum.map(rest_points, fn other_point ->
              {{point, other_point}, rectangle(point, other_point)}
            end)

        areas(rest_points, acc)

      [] ->
        Enum.sort_by(acc, fn {_points, distance} -> distance end, :desc)
    end
  end

  defp rectangle({x1, y1}, {x2, y2}) do
    (abs(x1 - x2) + 1) * (abs(y1 - y2) + 1)
  end

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day09.part2("example.txt")
    24
    iex> Aoc25.Day09.part2("input.txt")
    1552139370
  """
  def part2(file_path) do
    vs =
      file_path
      |> Aoc.get_input()
      |> Aoc.extract_numbers()
      |> Enum.map(&Kernel./(&1, 1))
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)

    edges = Enum.zip(vs, tl(vs) ++ [hd(vs)])

    areas = areas(vs)

    Enum.find_value(areas, fn {{{x1, y1}, {x2, y2}}, area} ->
      # We change order here to properly provide line_segments
      p1 = {x1, y1}
      p2 = {x1, y2}
      p3 = {x2, y2}
      p4 = {x2, y1}

      no_intersections? =
        edges
        |> Enum.flat_map(
          &[
            intersect?({p1, p2}, &1),
            intersect?({p2, p3}, &1),
            intersect?({p3, p4}, &1),
            intersect?({p4, p1}, &1),
            intersect?({p1, p3}, &1),
            intersect?({p2, p4}, &1)
          ]
        )
        |> Enum.all?(&(&1 == false))

      if no_intersections? do
        trunc(area)
      end
    end)
  end

  defp intersect?(line_seg1, line_seg2) do
    case Aoc.intersect_at_point(line_seg1, line_seg2) do
      {:cross, _} -> true
      _ -> false
    end
  end
end
