defmodule Blockchain.Block do
  @keys [
    :index,
    :previous_hash,
    :timestamp,
    :data,
    :hash
  ]
  @enforce_keys @keys
  defstruct @keys
end
