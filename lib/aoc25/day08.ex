defmodule Aoc25.Day08 do
  @moduledoc "https://adventofcode.com/2025/day/8"

  import Aoc

  require Aoc

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day08.part1("example.txt", 10)
    40
    iex> Aoc25.Day08.part1("input.txt")
    52668
  """
  def part1(file_path, take_n \\ 1000) do
    file_path
    |> points()
    |> compare()
    |> Enum.sort_by(fn {_, value} -> value end)
    |> Enum.take(take_n)
    |> connect()
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  @doc ~S"""
  ## Eamples
    iex> Aoc25.Day08.part2("example.txt")
    25272
    iex> Aoc25.Day08.part2("input.txt")
    1474050600
  """
  def part2(file_path) do
    points = points(file_path)

    all_connected? = fn
      [map_set] -> length(points) == MapSet.size(map_set)
      _ -> false
    end

    points
    |> compare()
    |> Enum.sort_by(fn {_, value} -> value end)
    |> connect_until(all_connected?)
    |> then(fn {{x1, _, _}, {x2, _, _}} -> x1 * x2 end)
  end

  defp points(file_path) do
    file_path
    |> Aoc.get_input()
    |> Aoc.extract_numbers()
    |> Enum.chunk_every(3)
    |> Enum.map(&List.to_tuple/1)
  end

  defp compare(coll, acc \\ %{}) do
    case coll do
      [_] ->
        acc

      [p1 | rest_points] ->
        rest_points
        |> Map.new(fn p2 -> {{p2, p1}, Aoc.euclidean_distance(p1, p2)} end)
        |> Enum.into(acc)
        ~> compare(rest_points)
    end
  end

  defp connect(list, acc \\ []) do
    case list do
      [] -> acc
      [{{p1, p2}, _distance} | rest] -> connect(rest, connect_point(acc, p1, p2))
    end
  end

  defp connect_until([{{p1, p2}, _distance} | tail], predicate?, acc \\ []) do
    acc = connect_point(acc, p1, p2)

    if predicate?.(acc) do
      {p1, p2}
    else
      connect_until(tail, predicate?, acc)
    end
  end

  defp connect_point(result \\ [], connected \\ MapSet.new(), connections, p1, p2) do
    case connections do
      [] ->
        if Enum.empty?(connected) do
          [MapSet.new([p1, p2]) | result]
        else
          [connected | result]
        end

      [first | rest] ->
        if MapSet.member?(first, p1) or MapSet.member?(first, p2) do
          connected = first |> MapSet.put(p1) |> MapSet.put(p2) |> MapSet.union(connected)
          connect_point(result, connected, rest, p1, p2)
        else
          connect_point([first | result], connected, rest, p1, p2)
        end
    end
  end
end
