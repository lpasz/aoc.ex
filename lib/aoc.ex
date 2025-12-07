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

  def extract_positive_numbers(input) do
    ~r"\d+"
    |> Regex.scan(input)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
  end

  def extract_numbers(input) do
    ~r"[-]?\d+"
    |> Regex.scan(input)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  We are using the polygon version.
  See more: https://en.wikipedia.org/wiki/Shoelace_formula
  """
  def shoelace(polygon_points) do
    polygon_points
    |> Enum.chunk_every(2, 1, :dicard)
    |> Enum.map(fn [[x1, y1], [x2, y2]] -> (y1 + y2) * (x1 - x2) end)
    |> Enum.sum()
    |> div(2)
    |> abs()
  end

  @doc """
  Normaly used to find the area, since we found the area with shoelace, we are using it to get the number of internal points.
  See more: https://en.wikipedia.org/wiki/Pick%27s_theorem
  """
  def pick_theorem_internal_points(area, polygon_points_count) do
    area - (div(polygon_points_count, 2) - 1)
  end

  def line_intersection(line1, line2) do
    div = line2.slope - line1.slope

    if div == 0 do
      nil
    else
      x = (line1.offset - line2.offset) / div
      y = line1.slope * x + line1.offset
      {x, y}
    end
  end

  def compute_line({x1, y1}, {x2, y2}) do
    if not (x2 - x1 == 0) do
      m = (y2 - y1) / (x2 - x1)

      %{slope: m, offset: y1 - m * x1}
    end
  end

  def compute_point_for_x({x1, y1}, slope, x) do
    {x, slope * (x - x1) * y1}
  end

  def numbers_per_line(string) do
    string
    |> String.split("\n")
    |> Enum.map(&Regex.scan(~r/\d+/, &1))
    |> Enum.map(&List.flatten/1)
    |> Enum.map(&to_int/1)
  end

  def parse_matrix(text, fun \\ & &1) do
    text
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.map(&Enum.map(&1, fun))
  end

  def parse_matrix_map(text, splitter \\ &String.codepoints/1, fun \\ & &1) do
    text
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

  def flatten_once(list) do
    Enum.flat_map(list, &Function.identity/1)
  end

  @doc """
  Constructs the full, absolute path to an asset file based on the calling module's name.

  ## Examples
      # If called from Aoc25.Day01
      Aoc.input_path("input.txt")
      # => "assets/aoc25/day01/input.txt"
  """
  defmacro get_input(file) do
    module = __CALLER__.module

    quote do
      # Get the calling module's name (e.g., Aoc25.Day01)

      # Extract the year suffix (YY) and day (DD) from the module name
      # Elixir.Aoc25.Day01 -> ["Aoc", "25", "Day", "01"]
      parts =
        unquote(module)
        |> Atom.to_string()
        |> String.split(["Elixir", "Aoc", ".", "Day"], trim: true)

      case parts do
        [y_suffix, d_pad] ->
          # Construct the asset directory path: "assets/aocYY/dayDD"
          dir = Path.join(["assets", "aoc#{y_suffix}", "day#{d_pad}"])
          path = Path.join(dir, unquote(file))
          File.read!(path)

        _ ->
          raise "Aoc.input_path/1 must be called from a module with name pattern AocYY.DayDD, got: #{unquote(module)}"
      end
    end
  end

  @doc """
  Stores example input for an Advent of Code day file.

  This macro captures the file path and line number from the call site
  using __CALLER__, which is only safe to access inside the defmacro body.
  """
  defmacro put_example(example_input, file_name \\ "example.txt") do
    # Capture __CALLER__ data (like file and line) immediately in the macro body.
    caller = __CALLER__

    # We now call a private helper function, passing the caller data.
    do_put_example(example_input, file_name, caller)
  end

  # Helper function (not a macro) that does the actual work.
  defp do_put_example(example_input, file_name, caller) do
    # 1. Get the calling module's file path as a string and strip the 'lib/' prefix.
    # E.g., from "lib/aoc25/day04.ex" to "aoc25/day04.ex"
    full_file_path = caller.file |> to_string() |> String.trim_leading("lib/")

    # 2. Get the root path without extension.
    # E.g., "aoc25/day04"
    base_path = Path.rootname(full_file_path)

    # 3. Construct the full target path, preserving the structure and using "assets/" as the root.
    # This results in: "assets/aoc25/day04.txt"
    target_path = Path.join(["assets", base_path, file_name])

    # 4. The directory we need to create is derived from the target path (e.g., "assets/aoc25")
    inputs_dir = Path.dirname(target_path)

    # 5. Perform the side-effect (file writing) immediately upon compilation.
    File.mkdir_p!(inputs_dir)
    File.write!(target_path, example_input)

    quote do
      # 6. Provide feedback during compilation.
      IO.puts("--- AoC Example Input Written ---")
      IO.puts("Source Module: #{unquote(full_file_path)} (Line: #{unquote(caller.line)})")
      IO.puts("Input File Created: #{unquote(target_path)}")

      :ok
    end
  end
end
