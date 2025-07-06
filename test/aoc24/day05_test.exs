defmodule Aoc24.Day05Test do
  use ExUnit.Case, async: true

  alias Aoc24.Day05

  test "example part1" do
    assert 143 = Day05.part1("assets/aoc24/day05/example.txt")
  end

  test "input part1" do
    assert 7365 = Day05.part1("assets/aoc24/day05/input.txt")
  end

  test "example part2" do
    assert 123 = Day05.part2("assets/aoc24/day05/example.txt")
  end

  # test "input part2" do
  #   assert 5770 = Day05.part2("assets/aoc24/day05/input.txt")
  # end
end
