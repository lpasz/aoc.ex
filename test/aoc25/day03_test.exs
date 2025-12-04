defmodule Aoc25.Day03Test do
  use ExUnit.Case, async: true

  alias Aoc25.Day03

  @example "./assets/aoc25/day03/example.txt"
  @input "./assets/aoc25/day03/input.txt"

  test "example" do
    assert Day03.part1(@example) == 357
  end

  test "part1" do
    assert Day03.part1(@input) == 17_193
  end

  test "example2" do
    assert Day03.part2(@example) == 3_121_910_778_619
  end

  test "part2" do
    assert Day03.part2(@input) == 171_297_349_921_310
  end
end
