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
    |> all_paths("you", "out")
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

    Aoc.count_paths(graph, "svr", "dac") *
      Aoc.count_paths(graph, "dac", "fft") *
      Aoc.count_paths(graph, "fft", "out") +
      Aoc.count_paths(graph, "svr", "fft") *
        Aoc.count_paths(graph, "fft", "dac") *
        Aoc.count_paths(graph, "dac", "out")
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
