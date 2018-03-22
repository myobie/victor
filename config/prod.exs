use Mix.Config

config :logger, level: :info

config :victor, VictorWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  # url: [scheme: "https", host: "example.com", port: 443],
  # secret_key_base: "abcdxyz",
  static_url: [path: "/app/assets"],
  load_from_system_env: true,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true,
  root: ".",
  version: Application.spec(:victor, :vsn)

# config :victor, :deploy_notification_auth,
#   username: "username",
#   password: "password"

# config :victor, :websites, [
#   %{
#     host: "example.com",
#     repo: "/tmp/repos",
#     remote: "https://git.example.com/repo.git"
#   },
#   %{
#     host: "example.com",
#     repo: "/tmp/repos",
#     remote: "https://git.example.com/repo.git"
#     authentication: %{
#       visitor_authorize_uri: "https://auth.example.com/v1/authorize",
#       editor_authorize_uri: "https://auth.example.com/v1/authorize",
#       client_id: "victor",
#       redirect_uri: "https://example.com/app/auth/callback",
#       public_key: """
#       ...public jwk json...
#       """,
#       verifiers: [email_ends_with?: "@example.com"]
#     }
#   }
# ]
