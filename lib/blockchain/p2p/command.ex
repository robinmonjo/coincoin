defmodule Blockchain.P2P.Command do
  @ping "ping"
  @query_latest "query_latest" # to request latest block
  @query_all "query_all" # to request all the blockchain
  @response_blockchain "response_blockchain" # to receive a blockchain (all the chain or only latest block in an array)

  def parse(data) do
    case Poison.decode!(data) do
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
    {:ok, "sending back latest block\n"}
  end

  def run(@query_all) do
    {:ok, "sending back the entire chain\n"}
  end

  def run({@response_blockchain, _chain}) do
    {:ok, "handling incoming blockchain\n"}
  end
end
