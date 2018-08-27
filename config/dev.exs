use Mix.Config

config :victor, VictorWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  static_url: [path: "/app/assets"],
  watchers: [
    node: [
      System.find_executable("npm"),
      "run",
      "watch",
      cd: Path.expand("../assets", __DIR__)
    ]
  ],
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/victor_web/views/.*(ex)$},
      ~r{lib/victor_web/templates/.*(eex)$}
    ]
  ]

config :victor, Victor.Repo,
  username: System.get_env("USER"),
  password: "",
  database: "victor_dev",
  hostname: "localhost",
  pool_size: 10

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :victor, :deploy_notification_auth,
  username: "dev",
  password: "pa55w0rd"
