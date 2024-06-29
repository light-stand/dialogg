import Config

config :dialogg, Dialogg.Repo,
  database: "postgres",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :dialogg, ecto_repos: [Dialogg.Repo]
