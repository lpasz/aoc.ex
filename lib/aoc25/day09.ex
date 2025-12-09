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
        acc
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
    :todo
  """
  def part2(file_path) do
    vs =
      file_path
      |> Aoc.get_input()
      |> Aoc.extract_numbers()
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)

    IO.puts("\n1\n")
    areas = vs |> areas() |> Map.new()

    x_min = vs |> Enum.map(fn {x, _} -> x end) |> Enum.min()
    x_max = vs |> Enum.map(fn {x, _} -> x end) |> Enum.max()
    y_min = vs |> Enum.map(fn {_, y} -> y end) |> Enum.min()
    y_max = vs |> Enum.map(fn {_, y} -> y end) |> Enum.max()

    poly_with_borders =
      vs
      |> Enum.zip(tl(vs) ++ [hd(vs)])
      |> Enum.flat_map(&fill_borders/1)

    IO.puts("\n2\n")
    y_map = Enum.group_by(poly_with_borders, fn {_x, y} -> y end)

    IO.puts("\n3\n")

    for_result =
      for y <- y_min..y_max do
        IO.puts("3.1 y -> #{y}")

        line = Map.get(y_map, y)

        IO.puts("3.2 y -> #{y}")
        ranges =
          line
          |> Enum.map(fn {x, _y} -> x end)
          |> Enum.sort()
          |> Enum.uniq()
          |> Enum.chunk_every(2, 1, :discard)
          |> Enum.map(&List.to_tuple/1)
          |> Enum.map(fn {x1, x2} -> x1..x2 end)

        x_min..x_max
        |> Enum.filter(fn x -> Enum.any?(ranges, &(x in &1)) end)
        |> Enum.map(fn x -> {x, y} end)
      end

    IO.puts("\n4\n")

    for_result =
      for_result
      |> List.flatten()
      |> MapSet.new()

    IO.puts("\n5\n")

    areas
    |> Enum.map(fn {{p1, p2}, _area} -> extrapolate_points(p1, p2) end)
    |> Enum.filter(&MapSet.subset?(&1, for_result))
    |> Enum.map(&MapSet.size/1)
    |> Enum.max()

  end

  defp extrapolate_points({x1, y1}, {x2, y2}) do
    x_min = min(x1, x2)
    x_max = max(x1, x2)
    y_min = min(y1, y2)
    y_max = max(y1, y2)

    for_result =
      for x <- x_min..x_max, y <- y_min..y_max do
        {x, y}
      end

    MapSet.new(for_result)
  end

  defp fill_borders({{x1, y1}, {x2, y2}}) do
    if x1 == x2 do
      Enum.map(y1..y2, fn y -> {x1, y} end)
    else
      Enum.map(x1..x2, fn x -> {x, y1} end)
    end
  end
end
