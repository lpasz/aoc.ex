defmodule Aoc24.Day01Test do
  use ExUnit.Case, async: true

  alias Aoc24.Day01

  @example "./assets/aoc24/day01/example.txt"
  @input "./assets/aoc24/day01/input.txt"

  test "example" do
    assert Day01.part1(@example) == 11
  end

  test "part1" do
    assert Day01.part1(@input) == 2367773
  end

  test "example2" do
    assert Day01.part2(@example) == 31
  end

  test "part2" do
    assert Day01.part2(@input) == 21271939
  end
end 
