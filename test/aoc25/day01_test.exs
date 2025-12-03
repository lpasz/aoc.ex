defmodule Aoc25.Day01Test do
  use ExUnit.Case, async: true

  alias Aoc25.Day01

  @example "./assets/aoc25/day01/example.txt"
  @input "./assets/aoc25/day01/input.txt"

  test "example" do
    assert Day01.part1(@example) == 3
  end

  test "part1" do
    assert Day01.part1(@input) == 1064
  end

  test "example2" do
    assert Day01.part2(@example) == 6
  end

  test "part2" do
    assert Day01.part2(@input) == 6122
  end
end
