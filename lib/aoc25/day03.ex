defmodule Aoc25.Day03 do
  @moduledoc false
  def part1(file_path) do
    file_path
    |> parse()
    |> Enum.map(&max_seq_number_of(&1, 2))
    |> Enum.map(&Integer.undigits/1)
    |> Enum.sum()
  end

  def part2(file_path) do
    file_path
    |> parse()
    |> Enum.map(&max_seq_number_of(&1, 12))
    |> Enum.map(&Integer.undigits/1)
    |> Enum.sum()
  end

  defp parse(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&Integer.digits/1)
  end

  def max_seq_number_of(seq, size) do
    start_seq = Enum.take(seq, size)
    rest_seq = Enum.drop(seq, size)

    Enum.reduce(rest_seq, start_seq, fn i, acc ->
      1..size
      |> Enum.map(&(List.delete_at(acc, &1 - 1) ++ [i]))
      |> then(&[acc | &1])
      |> Enum.max_by(&Integer.undigits/1)
    end)
  end
end
