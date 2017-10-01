use Mix.Config

config :blockchain,
  proof_of_work: Blockchain.Test.ProofOfWork

config :blockchain, Blockchain.ProofOfWork,
  pow_difficulty: 1
