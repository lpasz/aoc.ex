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

    {_, area} =
      Enum.find(areas, fn {{{x1, y1}, {x2, y2}}, _area} ->
        p1 = {x1, y1}
        p2 = {x1, y2}
        p3 = {x2, y2}
        p4 = {x2, y1}

        edges
        |> Enum.flat_map(
          &[
            intersect_point({p1, p2}, &1),
            intersect_point({p2, p3}, &1),
            intersect_point({p3, p4}, &1),
            intersect_point({p4, p1}, &1),
            intersect_point({p1, p3}, &1),
            intersect_point({p2, p4}, &1)
          ]
        )
        |> Enum.all?(&(&1 == false))
      end)

    trunc(area)
  end

  def intersect_point({{x1, y1}, {x2, y2}}, {{x3, y3}, {x4, y4}}) do
    dx1 = x2 - x1
    dy1 = y2 - y1
    dx2 = x4 - x3
    dy2 = y4 - y3

    den = dx1 * dy2 - dy1 * dx2

    if den == 0 do
      # parallel
      false
    else
      t = ((x3 - x1) * dy2 - (y3 - y1) * dx2) / den
      u = ((x3 - x1) * dy1 - (y3 - y1) * dx1) / den

      if t > 0 and t < 1 and u > 0 and u < 1 do
        {x1 + t * dx1, y1 + t * dy1} not in [{x1, y1}, {x2, y2}, {x3, y3}, {x4, y4}]
        # not in [{x1, y1}, {x2, y2}, {x3, y3}, {x4, y4}]
        # {x1 + t * dx1, y1 + t * dy1}
      else
        # not cross
        false
      end
    end
  end
end
