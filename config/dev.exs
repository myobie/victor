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

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :victor, :deploy_notification_auth,
  username: "dev",
  password: "pa55w0rd"

hugo_docs_website = %{
  host: "localhost",
  repo: Path.expand("./hugo-dev/hugo-docs/"),
  remote: "https://github.com/gohugoio/hugoDocs.git"
}

config :victor, :websites, [
  hugo_docs_website
]

config :victor, :fallback_website, hugo_docs_website
