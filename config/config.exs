use Mix.Config

config :victor, ecto_repos: [Victor.Repo]

config :victor, VictorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FdK2P4V4GFC82a/sAXK43RL0Ny73aqvvJ6hovGL7+jIxX0m6Qylu31hL1WfuLr0L",
  render_errors: [view: VictorWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Victor.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :victor, :websites, []

import_config "#{Mix.env()}.exs"
