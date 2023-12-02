require IEx

defmodule AdventOfCode.Day01 do
  @moduledoc false

  import NimbleParsec

  def part1(args) do
    lines = String.split(args, "\n", trim: true)
    Enum.reduce(lines, 0, fn x, acc -> acc + get_calibration_value(x) end)
  end

  def get_calibration_value(line) when is_binary(line) do
    String.to_integer(first_num(line) <> last_num(line))
  end

  def first_num(line) do
    chars = String.codepoints(line)
    Enum.find(chars, &is_num/1)
  end

  def last_num(line) do
    first_num(String.reverse(line))
  end

  def is_num(char) do
    case Integer.parse(char) do
      {_i, ""} -> true
      :error -> false
    end
  end

  @choice_map %{
    "1" => "1",
    "2" => "2",
    "3" => "3",
    "4" => "4",
    "5" => "5",
    "6" => "6",
    "7" => "7",
    "8" => "8",
    "9" => "9",
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }

  @choice_map_reversed Enum.into(@choice_map, %{}, fn {k, v} -> {String.reverse(k), v} end)

  def choice_map_reversed do
    @choice_map_reversed
  end

  defparsec(
    :parse_numbers_forwards,
    eventually(choice(Enum.map(Map.keys(@choice_map), &string/1)))
  )

  defparsec(
    :parse_numbers_backwards,
    eventually(choice(Enum.map(Map.keys(@choice_map_reversed), &string/1)))
  )

  def part2(args) do
    lines = String.split(args, "\n", trim: true)
    Enum.reduce(lines, 0, fn x, acc -> acc + get_calibration_value_2(x) end)
  end

  def get_calibration_value_2(line) do
    {:ok, [forward | _], _, _, _, _} = parse_numbers_forwards(line)
    {:ok, [backward | _], _, _, _, _} = parse_numbers_backwards(String.reverse(line))

    String.to_integer(@choice_map[forward] <> @choice_map_reversed[backward])
  end
end
