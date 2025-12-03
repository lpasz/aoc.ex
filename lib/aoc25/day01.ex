defmodule Aoc25.Day01 do
  @moduledoc false
  def part1(file_path) do
    steps = parse(file_path)

    steps
    |> Enum.reduce(
      %{stop_at_zero: 0, current_position: 50},
      fn step, %{stop_at_zero: cnt, current_position: current_position} ->
        IO.inspect(%{stop_at_zero: cnt, current_position: current_position})

        case click(step, current_position) do
          0 -> %{stop_at_zero: cnt + 1, current_position: 0}
          num -> %{stop_at_zero: cnt, current_position: num}
        end
      end
    )
    |> Map.get(:stop_at_zero)
  end

  def click(step, current_position) do
    case step do
      {:left, num} -> left_clicks(num, current_position)
      {:right, num} -> right_clicks(num, current_position)
    end
  end

  def left_clicks(num, current_position) do
    cond do
      num == 0 -> current_position
      current_position == 0 -> left_clicks(num - 1, 99)
      :else -> left_clicks(num - 1, current_position - 1)
    end
  end

  def right_clicks(num, current_position) do
    cond do
      num == 0 -> current_position
      current_position == 99 -> right_clicks(num - 1, 0)
      :else -> right_clicks(num - 1, current_position + 1)
    end
  end

  def part2(file_path) do
    :boom
  end

  defp parse(file_path) do
    file_path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn
      "L" <> number -> {:left, String.to_integer(number)}
      "R" <> number -> {:right, String.to_integer(number)}
    end)
  end
end
