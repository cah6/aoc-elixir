import Config

config :advent_of_code, AdventOfCode.Input,
  allow_network?: true,
  session_cookie: System.get_env("ADVENT_OF_CODE_SESSION_COOKIE")

try do
  import_config "secrets.exs"
rescue
  _ -> :ok
end
