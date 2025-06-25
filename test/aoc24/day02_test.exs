defmodule Aoc24.Day02Test do
  use ExUnit.Case, async: true

  alias Aoc24.Day02

  @example "./assets/aoc24/day02/example.txt"
  @input "./assets/aoc24/day02/input.txt"

  test "example" do
    assert Day02.part1(@example) == 2
  end

  test "part1" do
    assert Day02.part1(@input) == 670
  end

  test "example2" do
    assert Day02.part2(@example) == 4
  end

  test "part2" do
    assert Day02.part2(@input) == 700
  end
end
