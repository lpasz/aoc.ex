defmodule Aoc24.Day02 do
  def part1(file_path) do
    file_path
    |> Aoc.read_matrix(&String.to_integer/1)
    |> Enum.count(&valid_line?/1)
  end

  defp valid_line?(line) do
    [{dir, _valid?} | _tail] = list = validate_line(line)

    Enum.all?(list, fn {d, v} -> d == dir and v end)
  end

  def part2(file_path) do
    file_path
    |> Aoc.read_matrix(&String.to_integer/1)
    |> Enum.count(&some_valid?/1)
  end

  defp some_valid?([h | t]), do: some_valid?([], h, t)

  defp some_valid?(prev, curr, next) do
    cond do
      next == [] -> valid_line?(prev)
      valid_line?(prev ++ next) -> true
      :else -> some_valid?(prev ++ [curr], hd(next), tl(next))
    end
  end

  defp validate_line(line) do
    line
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&validate_item/1)
  end

  defp validate_item([a, b]) do
    if a < b do
      {:inc, (b - a) in 1..3}
    else
      {:dec, (a - b) in 1..3}
    end
  end
end
