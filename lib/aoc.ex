defmodule Aoc do
  def read_matrix(file_path, fun \\ & &1) do
    file_path
    |> File.read!()
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.map(&Enum.map(&1, fun))
  end

  defmacro left ~> right do
    Macro.pipe(left, right, 1)
  end

  defdelegate to_int(string), to: String, as: :to_integer

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
