defmodule Blockchain.Block do
  @moduledoc "Provides Block struct and related block operations"

  alias Blockchain.{Block, Chain, Data, Crypto}

  @derive [Poison.Encoder]
  defstruct [
    :index,
    :previous_hash,
    :timestamp,
    :data, # must follow the Blockchain.Data protocol
    :nounce,
    :hash
  ]

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

  def generate_next_block(data) do
    generate_next_block(data, Chain.latest_block)
  end

  def generate_next_block(data, %Block{} = latest_block) do
    b = %Block {
      index: latest_block.index + 1,
      previous_hash: latest_block.hash,
      timestamp: System.system_time(:second),
      data: data
    }
    hash = compute_hash(b)
    %{b | hash: hash}
  end

  def compute_hash(%Block{index: i, previous_hash: h, timestamp: timestamp, data: data, nounce: nounce}) do
    "#{i}#{h}#{timestamp}#{Data.hash(data)}#{nounce}"
    |> Crypto.hash(:sha256)
    |> Base.encode16()
  end
end
