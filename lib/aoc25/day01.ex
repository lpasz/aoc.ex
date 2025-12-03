defmodule Aoc25.Day01 do
  @moduledoc false
  def part1(file_path) do
    steps = parse(file_path)

    steps
    |> Enum.reduce({0, 50}, fn step, {cnt, curr} ->
      case click(step, curr, cnt) do
        {_, 0} -> {cnt + 1, 0}
        {_, num} -> {cnt, num}
      end
    end)
    |> then(fn {acc, _} -> acc end)
  end

  def part2(file_path) do
    steps = parse(file_path)

    steps
    |> Enum.reduce({0, 50}, fn step, {cnt, curr} -> click(step, curr, cnt) end)
    |> then(fn {acc, _} -> acc end)
  end

  defp parse(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn
      "L" <> number -> {:left, String.to_integer(number)}
      "R" <> number -> {:right, String.to_integer(number)}
    end)
  end

  def click(step, current_position, acc) do
    case {step, current_position} do
      {{:left, 0}, _} -> {acc, current_position}
      {{:left, num}, 0} -> click({:left, num - 1}, 99, acc)
      {{:left, num}, 1} -> click({:left, num - 1}, 0, acc + 1)
      {{:left, num}, curr} -> click({:left, num - 1}, curr - 1, acc)
      {{:right, 0}, _} -> {acc, current_position}
      {{:right, num}, 99} -> click({:right, num - 1}, 0, acc + 1)
      {{:right, num}, curr} -> click({:right, num - 1}, curr + 1, acc)
    end
  end
end
