use Mix.Config

config :victor, VictorWeb.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn

config :victor, Victor.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("USER"),
  password: "",
  database: "victor_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
