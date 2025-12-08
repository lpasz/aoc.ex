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
    points = points(file_path)
    points_distances = compare(points)

    points_distances
    |> Enum.sort_by(fn {_, value} -> value end)
    |> Enum.take(take_n)
    |> connect()
    |> Enum.map(&MapSet.size/1)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp points(file_path) do
    file_path
    |> Aoc.get_input()
    |> Aoc.extract_numbers()
    |> Enum.chunk_every(3)
    |> Enum.map(&List.to_tuple/1)
  end

  defp connect(coll, acc \\ [])
  defp connect([], acc), do: acc

  defp connect([{{p1, p2}, _distance} | tail], acc) do
    {connected?, acc} = connect_to_existing(acc, p1, p2)

    if connected? do
      connect(tail, acc)
    else
      connect(tail, [MapSet.new([p1, p2]) | acc])
    end
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

    points
    |> compare()
    |> Enum.sort_by(fn {_, value} -> value end)
    |> connect_until_one(length(points), 0)
    |> then(fn {{x1, _, _}, {x2, _, _}} -> x1 * x2 end)
  end

  defp compare(coll, acc \\ %{}) do
    case coll do
      [_] ->
        acc

      [p1 | tail] ->
        tail
        |> Map.new(fn p2 -> {{p2, p1}, Aoc.euclidean_distance(p1, p2)} end)
        |> Enum.into(acc)
        ~> compare(tail)
    end
  end

  defp connect_to_existing(result \\ [], connected \\ MapSet.new(), existing, p1, p2) do
    case existing do
      [] ->
        if Enum.empty?(connected) do
          {false, result}
        else
          {true, [connected | result]}
        end

      [head | tail] ->
        if MapSet.member?(head, p1) or MapSet.member?(head, p2) do
          head
          |> MapSet.put(p1)
          |> MapSet.put(p2)
          |> MapSet.union(connected)
          ~> connect_to_existing(result, tail, p1, p2)
        else
          connect_to_existing([head | result], connected, tail, p1, p2)
        end
    end
  end

  defp connect_until_one(coll, size, cnt, acc \\ [])

  defp connect_until_one([{{p1, p2}, _distance} | tail], size, cnt, acc) do
    {connected?, acc} = connect_to_existing(acc, p1, p2)

    cond do
      length(acc) == 1 and acc |> List.first() |> MapSet.size() == size -> {p1, p2}
      connected? -> connect_until_one(tail, size, cnt + 1, acc)
      :else -> connect_until_one(tail, size, cnt + 1, [MapSet.new([p1, p2]) | acc])
    end
  end
end
