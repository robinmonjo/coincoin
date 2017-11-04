# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :blockchain_web, namespace: Blockchain.Web

# Configures the endpoint
config :blockchain_web, Blockchain.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9vaXK29C3eyUtCvvUnhMTNs8xi53qgZ9p6lJjyhe8QsN+cqj4wUpluSRGN+tdNtD",
  render_errors: [view: Blockchain.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Blockchain.Web.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :blockchain_web, :generators, context_app: :blockchain

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
