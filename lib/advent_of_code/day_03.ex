# Learned from other solutions: a good way to parse input like this is to use
# regex to find positions of items I care about, then just loop over that set.
# Can use this to find numbers in a string like ".*123....12"
defmodule AdventOfCode.Day03 do
  require IEx

  defmodule Streak do
    defstruct sum: 0, is_part_number: false, exponent: 0
  end

  defmodule Acc do
    defstruct total: 0, streak: %Streak{}
  end

  # Example input:
  # 467..
  # ...*.
  # ..35.
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

  def neighbors(matrix, x, y) do
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
  end

  def neighbor_is_symbol?(matrix, x, y) do
    neighbors(matrix, x, y)
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

  def part2(args) do
    matrix =
      args
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_charlist/1)
      |> Enum.map(&combine_numbers/1)

    Enum.reduce(Enum.with_index(matrix), 0, fn {line, y}, curr_sum ->
      total =
        Enum.reduce(Enum.with_index(line), 0, fn {value, x}, acc ->
          reduce_cell_part_2(matrix, value, x, y, acc)
        end)

      curr_sum + total
    end)
  end

  def reduce_cell_part_2(matrix, value, curr_x, curr_y, acc) do
    if value == "*" do
      neighbors = neighbors(matrix, curr_x, curr_y) |> Enum.filter(&is_number/1) |> Enum.uniq()

      # note: an edge case here (input did not hit) is if the same number appeared twice in the input, like:
      # 2 . 2
      # . * .
      # . 3 .
      # in this case I would compute 12=2*2*3 when it should have not been a gear
      if Enum.count(neighbors) == 2 do
        acc + Enum.at(neighbors, 0) * Enum.at(neighbors, 1)
      else
        acc
      end
    else
      acc
    end
  end

  # ["467", "467", "467", ".", "."] = combine_numbers(~c"467..")
  def combine_numbers(input) do
    # can I use Enum.chunk_while for this?
    final_acc_apply = fn xs, streak ->
      if streak == "" do
        xs
      else
        xs ++ [streak]
      end
    end

    {streak, total} =
      Enum.reduce(input, {"", []}, fn v, {streak, total} ->
        if is_digit?(v) do
          {streak <> <<v>>, total}
        else
          if "" == streak do
            {"", total ++ [<<v>>]}
          else
            {"", total ++ [streak | [<<v>>]]}
          end
        end
      end)

    total = final_acc_apply.(total, streak)

    IO.inspect(total)

    Enum.map(total, fn x ->
      case Integer.parse(x) do
        {x, _rem} -> List.duplicate(x, x |> Integer.digits() |> Enum.count())
        :error -> x
      end
    end)
    |> List.flatten()
  end
end
