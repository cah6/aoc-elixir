defmodule AdventOfCode.Day02 do
  import NimbleParsec

  defmodule Set do
    defstruct red: 0, green: 0, blue: 0
  end

  defmodule Game do
    defstruct id: 0, set: %{}
  end

  color = choice(["red", "green", "blue"] |> Enum.map(&string/1))

  def build_pull([n | [color | _]]) do
    %{String.to_existing_atom(color) => n}
  end

  pull =
    integer(min: 1)
    |> ignore(string(" "))
    |> concat(color)
    |> ignore(choice([string(", "), string("; "), empty()]))
    |> reduce({AdventOfCode.Day02, :build_pull, []})

  def combine_pulls([game_id | pulls]) do
    combined =
      Enum.reduce(pulls, %Set{}, fn pull, acc ->
        Map.merge(acc, pull, fn _, a, b -> max(a, b) end)
      end)

    %Game{id: game_id, set: combined}
  end

  # Example:
  # Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  defparsec(
    :parse_game,
    ignore(string("Game "))
    |> integer(min: 1)
    |> ignore(string(": "))
    |> concat(repeat(pull))
    |> reduce({AdventOfCode.Day02, :combine_pulls, []})
  )

  def calc_game_score(%Game{id: id, set: set}) do
    %Set{red: r, green: g, blue: b} = set

    if r > 12 || g > 13 || b > 14 do
      0
    else
      id
    end
  end

  @spec part1(binary()) :: any()
  def part1(args) do
    String.split(args, "\n", trim: true)
    |> Enum.map(&parse_game/1)
    |> Enum.map(fn {:ok, [game | _], _, _, _, _} -> game end)
    |> Enum.reduce(0, fn game, acc -> acc + calc_game_score(game) end)
  end

  def calc_game_score_part_2(%Game{set: set}) do
    %Set{red: r, green: g, blue: b} = set

    r * g * b
  end

  def part2(args) do
    String.split(args, "\n", trim: true)
    |> Enum.map(&parse_game/1)
    |> Enum.map(fn {:ok, [game | _], _, _, _, _} -> game end)
    |> Enum.reduce(0, fn game, acc -> acc + calc_game_score_part_2(game) end)
  end
end
