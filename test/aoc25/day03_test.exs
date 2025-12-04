defmodule Aoc25.Day03Test do
  use ExUnit.Case, async: true

  alias Aoc25.Day03

  @example "./assets/aoc25/day03/example.txt"
  @input "./assets/aoc25/day03/input.txt"

  test "example" do
    assert Day03.part1(@example) == 1227775554
  end

  test "part1" do
    assert Day03.part1(@input) == 20323751480
  end

  test "example2" do
    assert Day03.part2(@example) == 4174379265
  end

  test "part2" do
    assert Day03.part2(@input) == 30360171216
  end
end
