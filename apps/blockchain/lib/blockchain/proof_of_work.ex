defmodule Blockchain.ProofOfWork do
  @moduledoc """
  ProofOfWork contains functions to perform and verify proof-of-work
  https://en.bitcoin.it/wiki/Proof_of_work
  """

  alias Blockchain.Block

  # compute computes the proof of work of a given block
  # and returns a new block with the `nounce` field set
  # so its hash satisfies the PoW. Can take a while according
  # to the difficulty set in `pow_difficulty` config
  def compute(%Block{} = b) do
    {hash, nounce} = proof_of_work(b)
    %{b | hash: hash, nounce: nounce}
  end

  # verify that a givens hash satisfy the blockchain
  # proof-of-work
  def verify(hash) do
    prefix = Enum.reduce 1..difficulty(), "", fn(_, acc) -> "0#{acc}" end
    String.starts_with?(hash, prefix)
  end

  defp difficulty, do: Application.fetch_env!(:blockchain, :pow_difficulty)

  defp proof_of_work(%Block{} = block, nounce \\ 0) do
    b = %{block | nounce: nounce}
    hash = Block.compute_hash(b)
    case verify(hash) do
      true -> {hash, nounce}
      _ -> proof_of_work(block, nounce + 1)
    end
  end
end