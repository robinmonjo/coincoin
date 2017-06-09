defmodule Blockchain.P2P.Command do

  alias Blockchain.Chain

  @ping "ping"
  @query_latest "query_latest" # to request latest block
  @query_all "query_all" # to request all the blockchain
  @response_blockchain "response_blockchain" # to receive a blockchain (all the chain or only latest block in an array)

  def parse(data) do
    case Poison.decode(data) do
      {:ok, json} ->
        parse_cmd(json)
      {:error, {reason, _, _}} ->
        {:error, reason}
    end
  end

  def parse_cmd(json) do
    case json do
      %{"type" => @query_latest} ->
        {:ok, @query_latest}
      %{"type" => @query_all} ->
        {:ok, @query_all}
      %{"type" => @response_blockchain} ->
        {:ok, {@response_blockchain, "some payload"}}
      %{"type" => @ping} ->
        {:ok, @ping}
      _ ->
        {:error, :unknown_type}
    end
  end

  def run(@ping) do
    {:ok, "pong\n"}
  end

  def run(@query_latest) do
    payload = Poison.encode!([Chain.latest_block()])
    {:ok, payload <> "\n"}
  end

  def run(@query_all) do
    payload = Poison.encode!(Chain.all_blocks())
    {:ok, payload <> "\n"}
  end

  def run({@response_blockchain, _chain}) do
    {:ok, "handling incoming blockchain\n"}
  end
end
