defmodule Aoc25.Day02Test do
  use ExUnit.Case, async: true

  alias Aoc25.Day02

  @example "./assets/aoc25/day02/example.txt"
  @input "./assets/aoc25/day02/input.txt"

  test "example" do
    assert Day02.part1(@example) == 1_227_775_554
  end

  test "part1" do
    assert Day02.part1(@input) == 20_223_751_480
  end

  test "example2" do
    assert Day02.part2(@example) == 4_174_379_265
  end

  test "part2" do
    assert Day02.part2(@input) == 30_260_171_216
  end
end
