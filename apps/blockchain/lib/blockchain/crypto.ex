defmodule Blockchain.Crypto do
  @moduledoc """
  Wrapper around erlang crypto for easy piping
  """
  def hash(data, algo), do: :crypto.hash(algo, data)
end
