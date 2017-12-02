use Mix.Config

# The module to use as the underlying blockchain
# should expose add/1 and blocks/0
config :coincoin_token, blockchain: Coincoin.Blockchain

import_config "#{Mix.env()}.exs"
