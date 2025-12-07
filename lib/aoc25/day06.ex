defmodule Aoc25.Day06 do
  @moduledoc "https://adventofcode.com/2025/day/6"

  require Aoc

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day06.part1("example.txt")
    4277556
    iex> Aoc25.Day06.part1("input.txt")
    6417439773370
  """
  def part1(file_path) do
    file_path
    |> parse_input1()
    |> Aoc.transpose()
    |> Enum.map(fn line ->
      Enum.reduce(line, [], fn num, acc ->
        cond do
          is_number(num) -> [num | acc]
          "*" == num -> Enum.product(acc)
          "+" == num -> Enum.sum(acc)
        end
      end)
    end)
    |> Enum.sum()
  end

  defp parse_input1(file_path) do
    text =
      file_path
      |> Aoc.input_path()
      |> File.read!()
      |> String.split("\n", trim: true)

    for line <- text do
      case Aoc.extract_positive_numbers(line) do
        [] -> ~r/\*|\+/ |> Regex.scan(line) |> List.flatten()
        numbers -> numbers
      end
    end
  end

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day06.part2("example.txt")
    3263827
    iex> Aoc25.Day06.part2("input.txt")
    :todo
  """
  def part2(file_path) do
    parse(file_path)
  end

  defp parse(file_path) do
    file_path
    |> Aoc.input_path()
    |> File.read!()
    |> String.split("\n")
    |> Enum.reject(&String.trim(&1) == "")
    |> Enum.map(&String.codepoints/1)
    |> Enum.map(&Enum.reverse/1)
    |> IO.inspect()
    |> Aoc.transpose()
    |> Enum.map(&Enum.join/1)
    |> Enum.reduce({0, []}, fn itm, {acc, mid} ->
      IO.inspect(itm)
      case Regex.scan(~r/\d+|\+|\*/, itm) do
        [] -> {acc, mid}
        [[num], [operation]] -> {acc + operation(operation, [String.to_integer(num) | mid]), []}
        # [["+"]] -> {acc, [String.to_integer(num) | mid]}
        # [["*"]] -> {acc, [String.to_integer(num) | mid]}
        [[num]] -> {acc, [String.to_integer(num) | mid]}
      end
    end)
    |> elem(0)
  end

  defp operation("+", itms), do: Enum.sum(itms)
  defp operation("*", itms), do: Enum.product(itms)
end
