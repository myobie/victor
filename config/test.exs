use Mix.Config

config :victor, VictorWeb.Endpoint,
  http: [port: 4001],
  server: false

config :logger, level: :warn

config :victor, :hugo, path: Path.expand("./test/support/repo/")

config :victor, :open_id_connect,
  authorize_url: "http://example.com/authorize",
  redirect_uri: "http://example.com/app/auth/callback",
  public_key: ""

config :victor, :deploy_notification_auth,
  username: "dev",
  password: "pa55w0rd"

config :victor, :websites, [
  %{
    host: "www.example.com",
    repo: System.tmp_dir!(),
    remote: "https://example:@github.com/example/example.git"
  },
  %{
    host: "vsoexample.com",
    repo: System.tmp_dir!(),
    remote: "https://example:@example.visualstudio.com/_git/example"
  }
]
