defmodule Aoc25.Day11 do
  @moduledoc "https://adventofcode.com/2025/day/11"

  require Aoc

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day11.part1("example.txt")
    5
    # iex> Aoc25.Day11.part1("input.txt")
    # 670
  """
  def part1(file_path) do
    file_path
    |> parse()
    |> count_paths("you", "out")
  end

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day11.part2("example2.txt")
    2
    iex> Aoc25.Day11.part2("input.txt")
    332052564714990
  """
  def part2(file_path) do
    graph = parse(file_path)

    count_paths(graph, "svr", "dac") * count_paths(graph, "dac", "fft") * count_paths(graph, "fft", "out") +
      count_paths(graph, "svr", "fft") * count_paths(graph, "fft", "dac") * count_paths(graph, "dac", "out")
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

  # this solution is absurdly faster, i need to understand why, because they are somewhat similar
  defp count_paths(graph, from, to) do
    {count, _} = find_path(graph, %{}, from, to)
    count
  end

  defp find_path(outputs, paths, from, to) do
    cond do
      from == to ->
        {1, paths}

      count = Map.get(paths, from) ->
        {count, paths}

      :else ->
        {count, new_paths} =
          outputs
          |> Map.get(from, [])
          |> Enum.reduce({0, paths}, fn next, {acc_count, acc_paths} ->
            {n_count, updated_paths} = find_path(outputs, acc_paths, next, to)
            {acc_count + n_count, updated_paths}
          end)

        {count, Map.put(new_paths, from, count)}
    end
  end

  # this one is much slower and wont even finish
  def all_paths(graph, start, target) do
    dfs(graph, start, target, [start], [])
  end

  defp dfs(graph, from, to, path, acc) do
    if from == to do
      [Enum.reverse(path) | acc]
    else
      graph
      |> Map.get(from, [])
      |> Enum.reduce(acc, fn next, acc ->
        if next in path do
          acc
        else
          dfs(graph, next, to, [next | path], acc)
        end
      end)
    end
  end
end
