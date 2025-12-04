defmodule Aoc25.Day02Test do
  use ExUnit.Case, async: true

  alias Aoc25.Day02

  @example "./assets/aoc25/day02/example.txt"
  @input "./assets/aoc25/day02/input.txt"

  test "example" do
    assert Day02.part1(@example) == 1227775554
  end

  test "part1" do
    assert Day02.part1(@input) == 20223751480
  end

  test "example2" do
    assert Day02.part2(@example) == 4174379265
  end

  test "part2" do
    assert Day02.part2(@input) == 30260171216
  end
end
