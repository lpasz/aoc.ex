defmodule Aoc24.Day03Test do
  use ExUnit.Case, async: true

  alias Aoc24.Day03

  @example "./assets/aoc24/day03/example.txt"
  @example2 "./assets/aoc24/day03/example2.txt"
  @input "./assets/aoc24/day03/input.txt"

  test "example" do
    assert Day03.part1(@example) == 161
  end

  test "part1" do
    assert Day03.part1(@input) == 179_571_322
  end

  test "example2" do
    assert Day03.part2(@example2) == 48
  end

  test "part2" do
    assert Day03.part2(@input) == 103_811_193
    2
  end
end
