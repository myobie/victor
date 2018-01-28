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
    repo: "test/support/repo/",
    remote: "https://example:@github.com/example/example.git"
  },
  %{
    host: "vsoexample.com",
    repo: "test/support/repo/",
    remote: "https://example:@example.visualstudio.com/_git/example",
    authentication: %{
      visitor_authorize_uri: "https://auth.example.com/authorize?provider=msft",
      editor_authorize_uri: "https://auth.example.com/authorize?provider=vso",
      client_id: "victor",
      redirect_uri: "https://vsoexample.com/app/auth/callback",
      public_key: """
      {"alg":"ES512","crv":"P-521","kty":"EC","use":"sig","x":"ADeqs4zY_YQ7yY1rXH28gE8mc0NeXYPrrqY77inWBBKMcxiHphKkL5tpBKJWTVYJ0FG2f_ZBujBXeOJuVp7e8YW2","y":"Ae_ZDDV8Mp4f0uDYSM_7CNR9C3GT6WWrqRRNxdzZUcFX3awN8PoWdzw1EeyIPIGR56tQkoqXl9bjjPrIFtccpWh5"}
      """,
      verifiers: [email_ends_with?: "@vsoexample.com"]
    }
  }
]

# This is the keypair to match the public key above
config :victor, :test_keypair, """
{"alg":"ES512","crv":"P-521","d":"jq9WLZBES-7WfYjKSztxKPXSIJGDBpXNHd-PdT-Bf-zSPSuRQZ0zdrdvJ1du5jbIl9T2N7SylmvTdSgm3e7-JSo","kty":"EC","use":"sig","x":"ADeqs4zY_YQ7yY1rXH28gE8mc0NeXYPrrqY77inWBBKMcxiHphKkL5tpBKJWTVYJ0FG2f_ZBujBXeOJuVp7e8YW2","y":"Ae_ZDDV8Mp4f0uDYSM_7CNR9C3GT6WWrqRRNxdzZUcFX3awN8PoWdzw1EeyIPIGR56tQkoqXl9bjjPrIFtccpWh5"}
"""
