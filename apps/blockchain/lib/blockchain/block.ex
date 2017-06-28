defmodule Blockchain.Block do
  @moduledoc "Provides Block struct and related block operations"

  alias Blockchain.{Block, Chain}

  @derive [Poison.Encoder]
  defstruct [
    :index,
    :previous_hash,
    :timestamp,
    :data,
    :nounce,
    :hash
  ]

  def genesis_block do
    %Block{
      index: 0,
      previous_hash: "0",
      timestamp: 1_465_154_705,
      data: "genesis block",
      nounce: 35679,
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
    b = %{b | nounce: proof_of_work(b)}
    hash = compute_hash(b)
    %{b | hash: hash}
  end

  def compute_hash(%Block{index: i, previous_hash: h, timestamp: timestamp, data: data, nounce: nounce}) do
    :crypto.hash(:sha256, "#{i}#{h}#{timestamp}#{data}#{nounce}") |> Base.encode16
  end

  # https://en.bitcoin.it/wiki/Proof_of_work
  defp proof_of_work(%Block{} = block, nounce \\ 0) do
    b = %{block | nounce: nounce}
    hash = compute_hash(b)
    case verify_proof_of_work(hash) do
      true -> nounce
      _ -> proof_of_work(block, nounce + 1)
    end
  end

  def verify_proof_of_work(hash) do
    difficulty = Application.fetch_env!(:blockchain, :pow_difficulty)
    prefix = Enum.reduce 1..difficulty, "", fn(_, acc) -> "0#{acc}" end
    String.starts_with?(hash, prefix)
  end
end
