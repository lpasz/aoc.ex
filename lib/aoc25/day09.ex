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
    iex> Aoc25.Day09.part2("example_edgecase.txt")
    12
    iex> Aoc25.Day09.part2("input.txt")
    1552139370
  """
  def part2(file_path) do
    vs =
      file_path
      |> Aoc.get_input()
      |> Aoc.extract_numbers()
      # |> Enum.map(&Kernel./(&1, 1))
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)

    edges = Enum.zip(vs, tl(vs) ++ [hd(vs)])

    areas = areas(vs)

    IO.inspect(total: length(areas))

    Enum.reduce_while(areas, %{}, fn {_, total_area} = area, acc ->
      IO.inspect(area: area)
      borders = rectangle_border_points(area)

      case Enum.reduce_while(borders, acc, fn point, acc ->
             {in?, acc} = wind(edges, point, acc)

             if in? do
               {:cont, acc}
             else
               {:halt, {in?, acc}}
             end
           end) do
        {false, acc} -> {:cont, acc}
        _acc -> {:halt, total_area}
      end
    end)
  end

  defp rectangle_border_points({{{x1, y1}, {x2, y2}}, _area}) do
    p1 = {x1, y1}
    p2 = {x1, y2}
    p3 = {x2, y2}
    p4 = {x2, y1}
    fill(p1, p2) ++ fill(p2, p3) ++ fill(p3, p4) ++ fill(p4, p1)
  end

  defp fill({x1, y1}, {x2, y2}) do
    if x1 == x2 do
      Enum.map(y1..y2, &{x1, &1})
    else
      Enum.map(x1..x2, &{&1, y1})
    end
  end

  defp intersect?(line_seg1, line_seg2) do
    case Aoc.intersect_at_point(line_seg1, line_seg2) do
      {:cross, _} -> true
      _ -> false
    end
  end

  defp wind(edges, {px, py}, cache \\ %{}) do
    case Map.get(cache, {px, py}) do
      nil ->
        value = do_wind(edges, {px, py})
        {value, Map.put(cache, {px, py}, value)}

      value ->
        {value, cache}
    end
  end

  defp do_wind(edges, {px, py}) do
    result =
      Enum.reduce_while(edges, 0, fn
        {{x1, y1}, {x2, y2}}, acc ->
          # --- Boundary Collision Check ---
          cross_product = (y2 - y1) * (px - x1) - (x2 - x1) * (py - y1)

          if cross_product == 0 and
               min(x1, x2) <= px and px <= max(x1, x2) and
               min(y1, y2) <= py and py <= max(y1, y2) do
            # Halt immediately if on boundary
            {:halt, :on_boundary}
          else
            # --- Winding Number Calculation ---
            new_acc =
              cond do
                # Upward edge crossing (y1 <= py < y2)
                y1 <= py and py < y2 ->
                  x_intersect = x1 + (py - y1) * (x2 - x1) / (y2 - y1)
                  if px < x_intersect, do: acc + 1, else: acc

                # Downward edge crossing (y2 <= py < y1)
                y2 <= py and py < y1 ->
                  x_intersect = x1 + (py - y1) * (x2 - x1) / (y2 - y1)
                  if px < x_intersect, do: acc - 1, else: acc

                # No crossing
                true ->
                  acc
              end

            # Continue iteration
            {:cont, new_acc}
          end
      end)

    # 3. Final Result Interpretation
    case result do
      :on_boundary ->
        true

      winding_number ->
        # The point is inside if the absolute winding number is non-zero
        abs(winding_number) > 0
    end
  end
end
