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
    iex> Aoc25.Day09.part2("example_edgecase.txt")
    12
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

    # this works for this example. but it's not a general solution
    # this will fail if there is a big c shaped where the void is bigger.
    # it will identify the void outside as the bigger square
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

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day09.part2_generic("example.txt")
    24
    iex> Aoc25.Day09.part2_generic("input.txt")
    1552139370
    iex> Aoc25.Day09.part2_generic("example_edgecase.txt")
    12
  """
  def part2_generic(file_path) do
    vs =
      file_path
      |> Aoc.get_input()
      |> Aoc.extract_numbers()
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)

    edges = Enum.zip(vs, tl(vs) ++ [hd(vs)])

    areas = areas(vs)

    fun = fn point, {_, acc} ->
      {in?, acc} = wind(edges, point, acc)

      if in? do
        {:cont, {in?, acc}}
      else
        {:halt, {in?, acc}}
      end
    end

    Enum.reduce_while(areas, %{}, fn {{{x1, y1}, {x2, y2}}, total_area}, acc ->
      p1 = {x1, y1}
      p2 = {x1, y2}
      p3 = {x2, y2}
      p4 = {x2, y1}

      # this nonsense speed things up by quite a lot, we don't need to create all borders at once
      with {true, acc} <- wind(edges, p1, acc),
           {true, acc} <- wind(edges, p2, acc),
           {true, acc} <- wind(edges, p3, acc),
           {true, acc} <- wind(edges, p4, acc),
           {true, acc} <- Enum.reduce_while(fill(p1, p2), {nil, acc}, fun),
           {true, acc} <- Enum.reduce_while(fill(p2, p3), {nil, acc}, fun),
           {true, acc} <- Enum.reduce_while(fill(p3, p4), {nil, acc}, fun),
           {true, _acc} <- Enum.reduce_while(fill(p4, p1), {nil, acc}, fun) do
        {:halt, total_area}
      else
        {false, acc} -> {:cont, acc}
      end
    end)
  end

  defp fill({x1, y1}, {x2, y2}) do
    if x1 == x2 do
      Enum.map(y1..y2, &{x1, &1})
    else
      Enum.map(x1..x2, &{&1, y1})
    end
  end

  defp wind(edges, {px, py}, cache) do
    case Map.get(cache, {px, py}) do
      nil ->
        value = do_wind(edges, {px, py})
        {value, Map.put(cache, {px, py}, value)}

      value ->
        {value, cache}
    end
  end

  @inside 1

  defp do_wind(edges, p3) do
    edges
    |> Enum.reduce_while(0, fn {p1, p2}, acc ->
      cond do
        in_border?(p1, p2, p3) -> {:halt, @inside}
        upwards?(p1, p2, p3) and x_intersect?(p1, p2, p3) -> {:cont, acc + 1}
        downwards?(p1, p2, p3) and x_intersect?(p1, p2, p3) -> {:cont, acc - 1}
        :else -> {:cont, acc}
      end
    end)
    |> then(&(abs(&1) > 0))
  end

  defp in_border?({x1, y1}, {x2, y2}, {px, py}) do
    cross_product = (y2 - y1) * (px - x1) - (x2 - x1) * (py - y1)

    cross_product == 0 and min(x1, x2) <= px and px <= max(x1, x2) and min(y1, y2) <= py and py <= max(y1, y2)
  end

  defp upwards?({_x1, y1}, {_x2, y2}, {_px, py}) do
    y1 <= py and py < y2
  end

  defp downwards?({_x1, y1}, {_x2, y2}, {_px, py}) do
    y2 <= py and py < y1
  end

  defp x_intersect?({x1, y1}, {x2, y2}, {px, py}) do
    px < x1 + (py - y1) * (x2 - x1) / (y2 - y1)
  end
end
