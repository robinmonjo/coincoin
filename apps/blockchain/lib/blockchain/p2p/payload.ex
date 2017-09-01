defmodule Blockchain.P2P.Payload do
  @moduledoc "Data going throught to the P2P protocol"

  alias Blockchain.{Block, P2P.Payload}

  # simple ping
  @ping "ping"

  # to request latest block
  @query_latest "query_latest"

  # to request all the blockchain
  @query_all "query_all"

  # to receive a blockchain (all the chain or only latest block in an array)
  @response_blockchain "response_blockchain"

  # to transmit data to be mined
  @mining_request "mining_request"

  @derive [Poison.Encoder]
  defstruct [
    :type,
    :blocks,
    :data
  ]

  def ping, do: %Payload{type: @ping}

  def query_all, do: %Payload{type: @query_all}

  def query_latest, do: %Payload{type: @query_latest}

  def response_blockchain(chain), do: %Payload{type: @response_blockchain, blocks: chain}

  def mining_request(data), do: %Payload{type: @mining_request, data: data}

  def decode(input) do
    case Poison.decode(input, as: %Payload{blocks: [%Block{}]}) do
      {:ok, _} = result ->
        result
      {:error, {reason, _, _}} ->
        {:error, reason}
    end
  end

  def encode!(%Payload{} = payload), do: Poison.encode!(payload)
end
