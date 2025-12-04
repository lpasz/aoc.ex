defmodule Mix.Tasks.Aoc.Gen do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generates AoC module, assets, and tests with auto-download"

  def run(args) do
    # Parse options: -d 1 -y 2025
    {opts, _, _} = OptionParser.parse(args, switches: [day: :integer, year: :integer], aliases: [d: :day, y: :year])

    # Default to today if not provided
    today = Date.utc_today()
    day = opts[:day] || today.day
    year = opts[:year] || today.year

    # Formatting: 2025 -> "25", 1 -> "01"
    y_suffix = rem(year, 100)
    day_pad = String.pad_leading("#{day}", 2, "0")

    # Paths
    # lib/aoc25/day01.ex
    mod_path = "lib/aoc#{y_suffix}/day#{day_pad}.ex"
    # test/aoc25/day01_test.exs
    test_path = "test/aoc#{y_suffix}/day#{day_pad}_test.exs"
    # assets/aoc25/day01/
    asset_dir = "assets/aoc#{y_suffix}/day#{day_pad}"

    assigns = [
      year: year,
      y_suffix: y_suffix,
      day: day,
      day_pad: day_pad,
      asset_dir: asset_dir
    ]

    # 1. Create Directories
    create_directory(Path.dirname(mod_path))
    create_directory(Path.dirname(test_path))
    create_directory(asset_dir)

    # 2. Download Data (only input.txt now)
    download_inputs(year, day, asset_dir)

    # 3. Generate Code
    create_file(mod_path, solution_template(assigns))
    create_file(test_path, test_template(assigns))

    Mix.shell().info([:green, "\n✨ Ready for Day #{day}!"])
  end

  defp download_inputs(year, day, dir) do
    session = System.get_env("AOC_SESSION")

    if is_nil(session) do
      Mix.shell().info([:yellow, "⚠️  AOC_SESSION not found. Skipping input download."])
      # Create an empty file so the module path is valid
      create_file(Path.join(dir, "input.txt"), "")
    else
      headers = [{"cookie", "session=#{session}"}]

      # Download Real Input
      input_url = "https://adventofcode.com/#{year}/day/#{day}/input"
      case Req.get(input_url, headers: headers) do
        {:ok, %{status: 200, body: body}} ->
          create_file(Path.join(dir, "input.txt"), String.trim_trailing(body))
          Mix.shell().info([:green, "* Downloaded input.txt"])
        _ ->
          Mix.shell().error("Failed to download input. Check year/day and AOC_SESSION.")
      end
    end
  end

  # The extract_example function is removed.

  embed_template(:solution, """
  defmodule Aoc<%= @y_suffix %>.Day<%= @day_pad %> do
    @moduledoc "https://adventofcode.com/<%= @year %>/day/<%= @day %>"

    require Aoc

    def part1(file_path) do
      :todo
    end

    def part2(file_path) do
      :todo
    end
  end
  """)

  embed_template(:test, """
  defmodule Aoc<%= @y_suffix %>.Day<%= @day_pad %>Test do
    use ExUnit.Case, async: true

    require Aoc

    alias Aoc<%= @y_suffix %>.Day<%= @day_pad %>

    @input "./<%= @asset_dir %>/input.txt"

    test "part1 input" do
      # Replace :todo with the expected answer when you solve Part 1
      assert Day<%= @day_pad %>.part1(@input) == :boom
    end

    test "part2 input" do
      # Replace :todo with the expected answer when you solve Part 2
      assert Day<%= @day_pad %>.part2(@input) == :boom
    end
  end
  """)
end
