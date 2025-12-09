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
    nil # too high 4602673662 
  """
  def part2(file_path) do
    vs =
      file_path
      |> Aoc.get_input()
      |> Aoc.extract_numbers()
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)

    areas = vs |> areas() |> Map.new()

    points_to_check =
      Enum.map(areas, fn {{p1, p2}, _areas} -> {{p1, p2}, extrapolate_points(p1, p2)} end)

    points_to_check
    |> Enum.filter(fn {_, rectangle_points} -> Enum.all?(rectangle_points, &point_in_poly?(vs, &1)) end)
    |> Enum.map(fn {{p1, p2}, _rest} -> Map.get(areas, {p1, p2}) end)
    |> Enum.max()
  end

  defp extrapolate_points({x1, y1}, {x2, y2}) do
    # x_min = min(x1, x2)
    # x_max = max(x1, x2)
    # y_min = min(y1, y2)
    # y_max = max(y1, y2)

    # for x <- x_min..x_max, y <- y_min..y_max do
    #   {x, y}
    # end
    edges = [{x1, y1}, {x1, y2}, {x2, y2}, {x2, y1}]

    pairs = Enum.zip(edges, tl(edges) ++ [hd(edges)])

    Enum.flat_map(pairs, fn {{x1, y1}, {x2, y2}} ->
      if x1 == x2 do
        Enum.map(y1..y2, &{x1, &1})
      else
        Enum.map(x1..x2, &{&1, y1})
      end
    end)
  end

  def point_in_poly?(poly_vertices, {px, py}) when is_list(poly_vertices) do
    # 1. Create the cyclic list of edges: [(V0, V1), (V1, V2), ..., (VN-1, V0)]
    edges = Enum.zip(poly_vertices, tl(poly_vertices) ++ [hd(poly_vertices)])

    # 2. Use Enum.reduce_while to calculate the winding number and check boundary condition
    result =
      Enum.reduce_while(edges, 0, fn {{x1, y1}, {x2, y2}}, acc ->
        # --- Boundary Collision Check ---
        cross_product = (y2 - y1) * (px - x1) - (x2 - x1) * (py - y1)

        if cross_product == 0 and
             min(x1, x2) <= px and px <= max(x1, x2) and
             min(y1, y2) <= py and py <= max(y1, y2) do
          {:halt, :on_boundary}
        else
          # --- Winding Number Calculation ---
          new_acc =
            cond do
              # Upward edge crosses the ray (y1 <= py < y2)
              y1 <= py and py < y2 ->
                x_intersect = x1 + (py - y1) * (x2 - x1) / (y2 - y1)
                if px < x_intersect, do: acc + 1, else: acc

              # Downward edge crosses the ray (y2 <= py < y1)
              y2 <= py and py < y1 ->
                x_intersect = x1 + (py - y1) * (x2 - x1) / (y2 - y1)
                if px < x_intersect, do: acc - 1, else: acc

              # No crossing
              true ->
                acc
            end

          # Continue iteration with the new accumulator value
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
