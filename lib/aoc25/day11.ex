defmodule Aoc25.Day11 do
  @moduledoc "https://adventofcode.com/2025/day/11"

  require Aoc

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day11.part1("example.txt")
    5
    iex> Aoc25.Day11.part1("input.txt")
    670
  """
  def part1(file_path) do
    graph =
      file_path
      |> Aoc.get_input()
      |> String.split("\n")
      |> Map.new(fn line ->
        [key, rest] = String.split(line, ":")
        {key, String.split(rest, " ", trim: true)}
      end)

    count_paths(graph, "you", "out")
  end

  @doc ~S"""
  ## Examples
    # iex> Aoc25.Day11.part2("example2.txt")
    # 2
    iex> Aoc25.Day11.part2("input.txt")
    :todo
  """
  def part2(file_path) do
    graph = parse(file_path)

    count_paths(graph, "svr", "dac") *
      count_paths(graph, "dac", "fft") *
      count_paths(graph, "fft", "out") +
      count_paths(graph, "svr", "fft") *
        count_paths(graph, "fft", "dac") *
        count_paths(graph, "dac", "out")
  end

  defp parse(file_path) do
    file_path
    |> Aoc.get_input()
    |> String.split("\n", trim: true)
    |> Map.new(fn line ->
      [key, rest] = String.split(line, ":")
      {key, String.split(rest, " ", trim: true)}
    end)
  end

  defp count_paths(graph, from, to) do
    {count, _} = find_path(graph, %{}, from, to)
    count
  end

  defp find_path(outputs, paths, device, target) do
    cond do
      device == target ->
        {1, paths}

      Map.has_key?(paths, device) ->
        {Map.get(paths, device), paths}

      :else ->
        neighbors = Map.get(outputs, device, [])

        {count, new_paths} =
          Enum.reduce(neighbors, {0, paths}, fn neighbor, {acc_count, acc_paths} ->
            {n_count, updated_paths} = find_path(outputs, acc_paths, neighbor, target)
            {acc_count + n_count, updated_paths}
          end)

        {count, Map.put(new_paths, device, count)}
    end
  end
end
