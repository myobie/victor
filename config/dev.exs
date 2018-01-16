use Mix.Config

config :victor, VictorWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  static_url: [path: "/app/assets"],
  watchers: [
    node: [
      "node_modules/brunch/bin/brunch",
      "watch",
      "--stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :victor, VictorWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/victor_web/views/.*(ex)$},
      ~r{lib/victor_web/templates/.*(eex)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :victor, :hugo,
  url: "http://user:pass@git.example.com/example.git",
  path: Path.expand("./hugo-dev-site/")

config :victor, :open_id_connect,
  authorize_url: "http://auth.example.com/authorize",
  redirect_uri: "http://example.com/app/auth/callback",
  # TODO: instructions for generating keys
  public_key: ""

# token_verifier: {Victor.Verifier, :valid?} # The file lib/victor/token_verifier.ex is git ignored for convenience

config :victor, :deploy_notification_auth,
  username: "dev",
  password: "pa55w0rd"

import_config "dev.secret.exs"
