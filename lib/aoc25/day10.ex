defmodule Aoc25.Day10 do
  @moduledoc "https://adventofcode.com/2025/day/10"

  require Aoc

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day10.part1("example.txt")
    7
    iex> Aoc25.Day10.part1("input.txt")
    517
  """
  def part1(file_path) do
    items =
      file_path
      |> Aoc.get_input()
      |> parse()

    items
    |> Enum.map(&search_smallest(&1, %{&1.start_switches => 0}))
    |> Enum.sum()
  end

  defp search_smallest(item, next) do
    cnt_or_acc =
      Enum.reduce_while(next, %{}, fn {state, cnt}, acc ->
        item.buttons
        |> Enum.map(&button_press(state, &1))
        |> Enum.reduce_while(acc, fn state, acc ->
          if state == item.goal_switches do
            {:halt, {:halt, cnt + 1}}
          else
            {:cont, Map.put(acc, state, cnt + 1)}
          end
        end)
        |> case do
          {:halt, cnt} -> {:halt, cnt}
          acc -> {:cont, acc}
        end
      end)

    if is_integer(cnt_or_acc) do
      cnt_or_acc
    else
      search_smallest(item, cnt_or_acc)
    end
  end

  defp button_press(state, button) do
    Enum.reduce(button, state, fn press, state ->
      Map.update(state, press, false, &(not &1))
    end)
  end

  @doc ~S"""
  ## Examples
    iex> Aoc25.Day10.part2("example.txt")
    :todo
    iex> Aoc25.Day10.part2("input.txt")
    :todo
  """
  def part2(file_path) do
    Aoc.get_input(file_path)
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      switches = to_switches(line)

      %{
        start_switches: Map.new(switches, fn {idx, _} -> {idx, false} end),
        goal_switches: switches,
        buttons: to_buttons(line),
        joltage: to_joltage(line)
      }
    end)
  end

  defp to_switches(line) do
    [[switches]] = Regex.scan(~r|\[.*\]|, line)

    switches
    |> String.codepoints()
    |> Enum.flat_map(fn
      "." -> [false]
      "#" -> [true]
      _ -> []
    end)
    |> Enum.with_index(0)
    |> Map.new(fn {v, idx} -> {idx, v} end)
  end

  defp to_buttons(line) do
    [[buttons]] = Regex.scan(~r|\(.*\)|, line)

    buttons
    |> String.split("\) ")
    |> Enum.map(&Aoc.extract_numbers/1)
  end

  defp to_joltage(line) do
    [[joltage]] = Regex.scan(~r|\{.*\}|, line)

    joltage
    |> Aoc.extract_numbers()
    |> Enum.with_index(0)
    |> Map.new(fn {v, idx} -> {idx, v} end)
  end
end
