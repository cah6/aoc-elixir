defmodule AdventOfCode.Day03 do
  require IEx

  defmodule Streak do
    defstruct sum: 0, is_part_number: false, exponent: 0
  end

  defmodule Acc do
    defstruct total: 0, streak: %Streak{}
  end

  # Example input:
  # 467..114..
  # ...*......
  def part1(args) do
    matrix =
      args
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_charlist/1)

    Enum.reduce(Enum.with_index(matrix), 0, fn {line, y}, curr_sum ->
      new_line = Enum.reverse(Enum.with_index(line))

      total =
        Enum.reduce(new_line, %Acc{}, fn {curr_unicode, x}, acc ->
          AdventOfCode.Day03.reduce_cell(matrix, curr_unicode, x, y, acc)
        end).total

      curr_sum + total
    end)
  end

  def reduce_cell(matrix, curr_unicode, curr_x, curr_y, acc) do
    max_x = (matrix |> Enum.at(0) |> Enum.count()) - 1

    new_is_part_number = acc.streak.is_part_number || neighbor_is_symbol?(matrix, curr_x, curr_y)

    should_tally =
      new_is_part_number &&
        (curr_x == max_x || !is_digit?(matrix |> Enum.at(curr_y) |> Enum.at(curr_x - 1)))

    if is_digit?(curr_unicode) do
      this_digit = curr_unicode - 48
      this_value = this_digit * 10 ** acc.streak.exponent

      if should_tally do
        %{streak: %Streak{}, total: acc.total + this_value + acc.streak.sum}
      else
        %{
          streak: %Streak{
            sum: acc.streak.sum + this_value,
            is_part_number: new_is_part_number,
            exponent: acc.streak.exponent + 1
          },
          total: acc.total
        }
      end
    else
      %{streak: %Streak{}, total: acc.total}
    end
  end

  def neighbor_is_symbol?(matrix, x, y) do
    # start at top-left, go clockwise around
    [
      {x - 1, y - 1},
      {x, y + 1},
      {x + 1, y + 1},
      {x + 1, y},
      {x + 1, y - 1},
      {x, y - 1},
      {x - 1, y + 1},
      {x - 1, y}
    ]
    |> Enum.filter(fn {x, y} -> AdventOfCode.Day03.in_bounds?(matrix, x, y) end)
    |> Enum.map(fn {x, y} -> matrix |> Enum.at(y) |> Enum.at(x) end)
    |> Enum.filter(fn i -> !(is_digit?(i) || is_integer?(i)) end)
    |> Enum.empty?()
    |> Kernel.not()
  end

  def is_digit?(i) do
    i >= 48 && i <= 57
  end

  def is_integer?(i) do
    i == 46
  end

  def in_bounds?(matrix, x, y) do
    y >= 0 && y < Enum.count(matrix) && x >= 0 && x < Enum.count(Enum.at(matrix, y))
  end

  def part2(_args) do
  end
end
