defmodule Aoc do
  @moduledoc false
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
    |> Map.new()
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

  def digits_to_number(digits) do
    Enum.reduce(digits, 0, fn d, acc -> acc * 10 + d end)
  end

  @doc """
  Constructs the full, absolute path to an asset file based on the calling module's name.

  ## Examples
      # If called from Aoc25.Day01
      Aoc.input_path("input.txt")
      # => "assets/aoc25/day01/input.txt"
  """
  defmacro input_path(file) do
    quote do
      # Get the calling module's name (e.g., Aoc25.Day01)
      module_name = __CALLER__.module

      # Extract the year suffix (YY) and day (DD) from the module name
      # Aoc25.Day01 -> ["Aoc", "25", "Day", "01"]
      parts = module_name |> Atom.to_string() |> String.split(["Aoc", ".", "Day"], trim: true)

      case parts do
        [y_suffix, d_pad] ->
          # Construct the asset directory path: "assets/aocYY/dayDD"
          dir = Path.join(["assets", "aoc#{y_suffix}", "day#{d_pad}"])
          Path.join(dir, unquote(file))

        _ ->
          raise "Aoc.input_path/1 must be called from a module with name pattern AocYY.DayDD, got: #{module_name}"
      end
    end
  end

  @doc """
  A convenience macro that reads, trims, and splits the content of a file
  into a list of lines using the resolved path.

  ## Examples
      # If called from Aoc25.Day01, reads "assets/aoc25/day01/input.txt"
      Aoc.read_input("input.txt")
      # => ["line1", "line2", ...]
  """
  defmacro read_input(file) do
    quote do
      unquote(file)
      |> unquote(__MODULE__).input_path()
      |> File.read!()
      |> String.trim()
      |> String.split("\n", trim: true)
    end
  end

  @doc """
  Writes the given contents to a file inside the current module's asset directory.
  Useful for quickly adding example data from an IEx session or directly in test setup.

  Since this is a macro, the file writing will execute when the macro is expanded
  (i.e., when the code containing the call is run, such as during test execution).

  ## Examples
      # If called from Aoc25.Day01Test
      contents = \"""
      a=1
      b=2
      \"""
      Aoc.put_example(contents)
      # => Creates/updates "assets/aoc25/day01/example.txt"
  """
  defmacro put_example(contents, filename \\ "example.txt") do
    quote do
      # Get the calling module's name (e.g., Aoc25.Day01 or Aoc25.Day01Test)
      module_name = __CALLER__.module

      # Extract the year suffix (YY) and day (DD)
      parts = module_name |> Atom.to_string() |> String.split(["Aoc", ".", "Day", "Test"], trim: true)

      case parts do
        [y_suffix, d_pad] ->
          # Construct the asset directory path: "assets/aocYY/dayDD"
          dir = Path.join(["assets", "aoc#{y_suffix}", "day#{d_pad}"])

          # Unquote filename and contents to inject the values into the quoted code
          full_path = Path.join(dir, unquote(filename))

          # Ensure directory exists before writing
          File.mkdir_p!(dir)

          # Write content and return {:ok, path} or {:error, reason}
          File.write(full_path, unquote(contents))
          {:ok, full_path}

        _ ->
          {:error, "Aoc.put_example/2 must be called from a module with name pattern AocYY.DayDD or AocYY.DayDDTest."}
      end
    end
  end
end
