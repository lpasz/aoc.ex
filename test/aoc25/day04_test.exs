defmodule Aoc25.Day04Test do
  use ExUnit.Case, async: true

  alias Aoc25.Day04

  @example "example.txt"
  @input "input.txt"

  test "example" do
    assert Day04.part1(@example) == 13
  end

  test "part1" do
    assert Day04.part1(@input) == 1502
  end

  test "example2" do
    assert Day04.part2(@example) == 43
  end

  test "part2" do
    assert Day04.part2(@input) == 9083
  end
end
