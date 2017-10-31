use Mix.Config

config :victor, VictorWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  load_from_system_env: true,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:victor, :vsn),
  url: [scheme: "https", host: "auth.example.com", port: 443]

# NOTE: In your secret file add:
# config :victor, VictorWeb.Endpoint,
#   url: [scheme: "https", host: "example.com", port: 443],
#   secret_key_base: "xyz"

config :logger, level: :info

import_config "prod.secret.exs"
