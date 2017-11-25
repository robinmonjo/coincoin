defmodule Blockchain.Block do
  @moduledoc "Provides Block struct and related block operations"

  alias Blockchain.{Block, Chain, BlockData, Crypto}

  @type t :: %__MODULE__{
          index: integer,
          previous_hash: String.t(),
          timestamp: integer,
          data: BlockData.t(),
          nounce: integer | nil,
          hash: String.t() | nil
        }

  @derive [Poison.Encoder]
  defstruct [
    :index,
    :previous_hash,
    :timestamp,
    :data,
    :nounce,
    :hash
  ]

  @spec genesis_block() :: t
  def genesis_block do
    %Block{
      index: 0,
      previous_hash: "0",
      timestamp: 1_465_154_705,
      data: "genesis block",
      nounce: 35_679,
      hash: "0000DA3553676AC53CC20564D8E956D03A08F7747823439FDE74ABF8E7EADF60"
    }
  end

  @spec generate_next_block(BlockData.t(), t) :: t
  def generate_next_block(data, block \\ Chain.latest_block())

  def generate_next_block(data, %Block{} = latest_block) do
    b = %Block{
      index: latest_block.index + 1,
      previous_hash: latest_block.hash,
      timestamp: System.system_time(:second),
      data: data
    }

    hash = compute_hash(b)
    %{b | hash: hash}
  end

  @spec compute_hash(t) :: String.t()
  def compute_hash(%Block{index: i, previous_hash: h, timestamp: ts, data: data, nounce: n}) do
    "#{i}#{h}#{ts}#{BlockData.hash(data)}#{n}"
    |> Crypto.hash(:sha256)
    |> Base.encode16()
  end
end
