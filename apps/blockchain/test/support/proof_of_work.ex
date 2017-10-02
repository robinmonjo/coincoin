defmodule Blockchain.Test.ProofOfWork do
  @moduledoc """
  ProofOfWork module used for testing
  """

  alias Blockchain.Block

  def compute(%Block{} = b), do: b
  def verify(hash), do: !String.starts_with?(hash, "n")
end