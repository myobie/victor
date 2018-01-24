# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :victor, ecto_repos: []

# Configures the endpoint
config :victor, VictorWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FdK2P4V4GFC82a/sAXK43RL0Ny73aqvvJ6hovGL7+jIxX0m6Qylu31hL1WfuLr0L",
  render_errors: [view: VictorWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Victor.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :victor, :websites, [] # default is to have no websites -- override

# Victor needs to know where to get the hugo site from and where to
# keep it locally. Place something like this in one of the secret files:
#
#     config :victor, :websites, [
#       %{
#         host: "example.com",
#         repo: Path.expand("/tmp/victor/"),
#         remote: "https://github.com/user/repo.git"
#       }
#     ]

# Victor supports authentication by delegating to an OpenID Connect
# server. You can run your own by running :authority
# (https://github.com/myobie/authority)
# or using any of a number of OpenID Connect providers.
#
# Place something like this in one of the secret files:
#
#     config :victor, :websites, [
#       %{
#         # ...
#         authentication: %{
#           authorize_url: "https://auth.example.com/authorize", # the URL of the authorization endpiont of your OpenID Connect provider
#           redirect_uri: "https://blog.example.com/app/auth/callback", # the URL to victor (the path is always /app/auth/callback)
#           public_key: "{...jwk json here...}", # victor uses public/private keys to verify the signature of JWTs sent from the OpenID Connect provider
#           verifiers: [:everyone] # everyone means anyone who can successfully sign in at the authorize URL
#         }
#       }
#     ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
