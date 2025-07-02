defmodule Aoc24.Day04Test do
  use ExUnit.Case, async: true

  alias Aoc24.Day04

  test "example part1" do
    assert 18 = Day04.part1("assets/aoc24/day04/example.txt")
  end

  test "input part1" do
    assert 2427 = Day04.part1("assets/aoc24/day04/input.txt")
  end

  test "example part2" do
    assert 9 = Day04.part2("assets/aoc24/day04/example.txt")
  end

  test "input part2" do
    assert 1900 = Day04.part2("assets/aoc24/day04/input.txt")
  end
end
