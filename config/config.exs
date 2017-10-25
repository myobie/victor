# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :victor,
  ecto_repos: [Victor.Repo]

# Configures the endpoint
config :victor, VictorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FdK2P4V4GFC82a/sAXK43RL0Ny73aqvvJ6hovGL7+jIxX0m6Qylu31hL1WfuLr0L",
  render_errors: [view: VictorWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Victor.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
