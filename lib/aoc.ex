defmodule Aoc do
  def two_parts_input(file_path) do
    [a, b] =
      file_path
      |> File.read!()
      |> String.trim()
      |> String.split("\n\n")

    {a, b}
  end

  def numbers_per_line(string) do
    string
    |> String.split("\n")
    |> Enum.map(&Regex.scan(~r/\d+/, &1))
    |> Enum.map(&List.flatten/1)
    |> Enum.map(&to_int/1)
  end

  def read_matrix(file_path, fun \\ & &1) do
    file_path
    |> File.read!()
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.map(&Enum.map(&1, fun))
  end

  def read_matrix_map(file_path, splitter \\ &String.codepoints/1, fun \\ & &1) do
    file_path
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(splitter)
    |> Enum.with_index()
    |> Enum.flat_map(fn {values, y} ->
      values
      |> Enum.with_index()
      |> Enum.map(fn {value, x} -> {{x, y}, fun.(value)} end)
    end)
    |> Enum.into(%{})
  end

  def max_matrix(mtx) do
    [x, y] =
      mtx
      |> Map.keys()
      |> Enum.reduce(fn [x, y], acc ->
        if acc == nil do
          [xx, yy] = acc
          [max(x, xx), max(y, yy)]
        else
          [x, y]
        end
      end)

    {x, y}
  end

  defmacro left ~> right do
    Macro.pipe(left, right, 1)
  end

  defmacro left ~>> right do
    Macro.pipe(left, right, 2)
  end

  def to_int(string) when is_binary(string) do
    String.to_integer(string)
  end

  def to_int(list) when is_list(list) do
    Enum.map(list, &String.to_integer/1)
  end

  def alphabet do
    String.codepoints("abcdefghijklmnopqrstuvwxyz")
  end

  def around(point) do
    [
      up(point),
      down(point),
      left(point),
      right(point),
      point |> up() |> left(),
      point |> up() |> right(),
      point |> down() |> left(),
      point |> down() |> right()
    ]
  end

  def up({x, y}, n \\ 1), do: {x, y - n}
  def down({x, y}, n \\ 1), do: {x, y + n}
  def left({x, y}, n \\ 1), do: {x - n, y}
  def right({x, y}, n \\ 1), do: {x + n, y}

  @directions ~w|^ v < >|a

  def move(point, move, n \\ 1) do
    case move do
      :^ -> up(point, n)
      :v -> down(point, n)
      :< -> left(point, n)
      :> -> up(point, n)
    end
  end

  def up_down_left_right(point) do
    Enum.map(@directions, &move(point, &1))
  end

  def cross(point, n) when n >= 1 do
    range = Range.new(1, n)

    [
      Enum.map(range, &up(point, &1)),
      Enum.map(range, &down(point, &1)),
      Enum.map(range, &left(point, &1)),
      Enum.map(range, &right(point, &1))
    ]
  end

  def diagonals(point) do
    [
      point |> up() |> left(),
      point |> up() |> right(),
      point |> down() |> left(),
      point |> down() |> right()
    ]
  end

  def x(point, n) when n >= 1 do
    range = Range.new(1, n)

    [
      Enum.map(range, &(point |> up(&1) |> left(&1))),
      Enum.map(range, &(point |> up(&1) |> right(&1))),
      Enum.map(range, &(point |> down(&1) |> left(&1))),
      Enum.map(range, &(point |> down(&1) |> right(&1)))
    ]
  end

  def transpose(list) do
    Enum.zip_with(list, & &1)
  end

  def euclidean_distance({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end
end
