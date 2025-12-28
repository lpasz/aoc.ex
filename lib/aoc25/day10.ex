defmodule Aoc25.Day10 do
  @moduledoc "https://adventofcode.com/2025/day/10"
  import Bitwise

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
    |> Task.async_stream(fn item -> 
      search_smallest_bits(
        :queue.from_list([{item.start_bits, 0}]), 
        MapSet.new([item.start_bits]), 
        item
      )
    end)
    |> Enum.map(fn {:ok, res} -> res end)
    |> Enum.sum()
  end

  defp search_smallest_bits(q, visited, item) do
    case :queue.out(q) do
      {{:value, {current_state, dist}}, q} ->
        if current_state == item.goal_bits do
          dist
        else
          {new_q, new_v} = 
            Enum.reduce(item.buttons_bits, {q, visited}, fn btn_mask, {acc_q, acc_v} ->
              # Usando bxor/2 em vez de ^^^
              next_state = bxor(current_state, btn_mask)
              
              if MapSet.member?(acc_v, next_state) do
                {acc_q, acc_v}
              else
                {:queue.in({next_state, dist + 1}, acc_q), MapSet.put(acc_v, next_state)}
              end
            end)
          
          search_smallest_bits(new_q, new_v, item)
        end
      {:empty, _} -> 
        nil
    end
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, switches_str, buttons_str, _joltage_str] = Regex.run(~r/\[(.*)\] \((.*)\) \{(.*)\}/, line)
      
      len = String.length(switches_str)
      
      goal_bits = 
        switches_str
        |> String.replace(".", "0")
        |> String.replace("#", "1")
        |> String.to_integer(2)

      buttons_bits = 
        buttons_str
        |> String.split(") (")
        |> Enum.map(fn b ->
          b 
          |> Aoc.extract_numbers()
          |> Enum.reduce(0, fn idx, acc -> 
            # Usando bor/2 e bsl/2 em vez de | e <<<
            bor(acc, bsl(1, (len - 1 - idx)))
          end)
        end)

      %{
        start_bits: 0,
        goal_bits: goal_bits,
        buttons_bits: buttons_bits,
        len: len
      }
    end)
  end
end
