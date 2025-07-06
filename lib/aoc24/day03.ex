defmodule Aoc24.Day03 do
  @moduledoc false
  import Aoc

  def mul([_, a, b]), do: to_int(a) * to_int(b)

  def part1(file_path) do
    File.read!(file_path)
    ~> Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/)
    |> Enum.map(&mul/1)
    |> Enum.sum()
  end

  def part2(file_path) do
    File.read!(file_path)
    ~> Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\)/)
    |> Enum.reduce([0, true], fn
      ["do()"], [acc, _] -> [acc, true]
      ["don't()"], [acc, _] -> [acc, false]
      scan, [acc, true] -> [acc + mul(scan), true]
      _, [acc, false] -> [acc, false]
    end)
    |> List.first()
  end
end
