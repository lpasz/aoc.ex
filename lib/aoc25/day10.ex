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
    file_path
    |> Aoc.get_input()
    |> parse()
    |> Enum.map(&search_smallest_switches(&1, %{&1.start_switches => 0}))
    |> Enum.sum()
  end

  defp search_smallest_switches(item, next) do
    cnt_or_acc =
      Enum.reduce_while(next, %{}, fn {state, cnt}, acc ->
        item.buttons
        |> Enum.map(&button_press(state, &1))
        |> Enum.reduce_while(acc, fn state, acc ->
          cond do
            state == item.goal_switches -> {:halt, {:halt, cnt + 1}}
            Map.has_key?(acc, state) -> {:cont, acc}
            :else -> {:cont, Map.put(acc, state, cnt + 1)}
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
      search_smallest_switches(item, cnt_or_acc)
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
    33
    # iex> Aoc25.Day10.part2("input.txt")
    # :todo
  """
  def part2(file_path) do
    file_path
    |> Aoc.get_input()
    |> parse()
    |> Enum.map(&search_smallest_joltage(&1, %{&1.start_joltage => 0}))
    |> Enum.sum()
  end

  defp search_smallest_joltage(item, next, depth \\ 0) do
    IO.inspect(depth: depth)

    cnt_or_acc =
      Enum.reduce_while(next, %{}, fn {state, cnt}, acc ->
        item.buttons
        |> Enum.map(&button_press_joltage(state, &1))
        |> Enum.reduce_while(acc, fn state, acc ->
          if state == item.goal_joltage do
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
      search_smallest_joltage(item, cnt_or_acc, depth + 1)
    end
  end

  defp button_press_joltage(state, button) do
    Enum.reduce(button, state, fn press, state ->
      Map.update(state, press, 0, &(&1 + 1))
    end)
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      switches = to_switches(line)
      joltage = to_joltage(line)

      %{
        start_switches: Map.new(switches, fn {idx, _} -> {idx, false} end),
        goal_switches: switches,
        buttons: to_buttons(line),
        start_joltage: Map.new(joltage, fn {idx, _} -> {idx, 0} end),
        goal_joltage: joltage
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
