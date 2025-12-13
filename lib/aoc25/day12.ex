defmodule Aoc25.Day12 do
  @moduledoc "https://adventofcode.com/2025/day/12"

  import Bitwise

  require Aoc

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day12.part1("example.txt")
    :todo
    # iex> Aoc25.Day12.part1("input.txt")
    # :todo
  """
  def part1(file_path) do
    info = file_path |> parse() 

    Enum.count(info.spaces, &fits_space?(&1, info.presents))
  end

  def fits_space?(space, presents) do
    try_place(space.grid, space.width, space.height, space.requires, presents)
  end

  defp try_place(grid, w, h, requires, presents) do
    # IO.inspect([grid, w, h])

    case requires do
      [] ->
        true

      [present_id | rest] ->
        rotations = Map.fetch!(presents, present_id)

        Enum.any?(rotations, fn rotation ->
          # print_grid(grid, w, h)
          # print_piece(rotation)
          try_rotation(grid, w, h, rotation, rest, presents)
        end)
    end
  end

  defp try_rotation(grid, w, h, rotation, rest, presents) do
    # IO.inspect([grid, w, h])
    piece_height = length(rotation)

    piece_width =
      rotation
      |> Enum.map(&Integer.to_string(&1, 2))
      |> Enum.map(&byte_size/1)
      |> Enum.max()

    max_y = h - piece_height
    max_x = w - piece_width

    Enum.any?(0..max_y, fn y ->
      Enum.any?(0..max_x, fn x ->
        # print_grid(grid, w, h, "grid")
        # print_piece(rotation)
        try_position(grid, w, h, rotation, x, y, rest, presents)
      end)
    end)
  end

  defp try_position(grid, grid_width, h, rows, x, y, rest, presents) do
    rows
    |> Enum.with_index()
    |> Enum.reduce_while({:ok, grid}, fn {row_mask, dy}, {:ok, acc} ->
      shift = (y + dy) * grid_width + x

      if (row_mask <<< shift &&& grid) == 0 do
        {:cont, {:ok, acc ||| row_mask <<< shift}}
      else
        {:halt, {:error, :colision}}
      end
    end)
    |> case do
      {:ok, new_grid} -> try_place(new_grid, grid_width, h, rest, presents)
      {:error, :colision} -> false
    end
  end

  defp print_grid(grid, width, height, label \\ "") do
    IO.puts(label)

    for y <- 0..(height - 1) do
      row =
        for x <- 0..(width - 1) do
          bit_index = y * width + x
          bit = grid >>> bit_index &&& 1
          if bit == 1, do: "#", else: "."
        end

      IO.puts(Enum.join(row))
    end

    IO.puts("")
  end

  def print_piece(rows) do
    rows
    |> Enum.map_join("\n", fn row ->
      row
      |> Integer.digits(2)
      |> Enum.map_join(&if &1 == 1, do: "#", else: ".")
    end)
    |> IO.puts()
  end

  defp parse(file_path) do
    presents_and_spaces = file_path |> Aoc.get_input() |> String.split("\n\n")
    spaces = List.last(presents_and_spaces)
    presents = List.delete(presents_and_spaces, spaces)

    %{
      presents: parse_presents(presents),
      spaces:
        spaces
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_spaces/1)
    }
  end

  defp parse_presents(presents) do
    Enum.reduce(presents, %{}, &parse_present/2)
  end

  defp parse_present(present, acc) do
    [number | rest] = String.split(present, "\n")

    {num, _} = Integer.parse(number)
    [line | _rest] = rest
    mtx = Enum.map(rest, &Aoc.to_mask(&1, [?#]))

    mtx1 = Aoc.masks_to_matrix(mtx, String.length(line))
    mtx2 = Aoc.transpose(mtx1)
    mtx3 = Enum.map(mtx1, &Enum.reverse/1)
    mtx4 = Enum.map(mtx2, &Enum.reverse/1)

    mtxs = Enum.map([mtx1, mtx2, mtx3, mtx4], &shape_info/1)

    Map.put(acc, num, mtxs)
  end

  defp shape_info(matrix) do
    Enum.map(matrix, &Integer.undigits(&1, 2))
  end

  defp parse_spaces(spaces) do
    IO.inspect(spaces)
    [n1, n2 | rest] = Aoc.extract_numbers(spaces)

    requires =
      rest
      |> IO.inspect()
      |> Enum.with_index(0)
      |> Enum.flat_map(fn {cnt, value} ->
        fn -> value end
        |> Stream.repeatedly()
        |> Enum.take(cnt)
      end)

    # grid = Enum.map(1..n1, fn _ -> 0 end)

    %{requires: requires, grid: 0, height: n1, width: n2}
  end

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day12.part2("example.txt")
    :todo
    iex> Aoc25.Day12.part2("input.txt")
    :todo
  """
  def part2(file_path) do
    Aoc.get_input(file_path)
  end
end
