require Logger

defmodule Blockchain.P2P.Command do
  @moduledoc "TCP server commands"

  alias Blockchain.{Chain, Block, P2P.Payload, P2P.Server, Mining}

  # reception

  def handle(data) do
    case Payload.decode(data) do
      {:ok, payload} ->
        handle_payload(payload)
      {:error, _reason} = err ->
        err
    end
  end

  defp handle_payload(%Payload{type: "ping"}) do
    {:ok, "pong"}
  end

  defp handle_payload(%Payload{type: "query_latest"}) do
    Logger.info fn -> "asking for latest block" end
    response =
      [Chain.latest_block()]
      |> Payload.response_blockchain()
      |> Payload.encode!()
    {:ok, response}
  end

  defp handle_payload(%Payload{type: "query_all"}) do
    Logger.info fn -> "asking for all blocks" end
    response =
      Chain.all_blocks()
      |> Payload.response_blockchain()
      |> Payload.encode!()
    {:ok, response}
  end

  defp handle_payload(%Payload{type: "response_blockchain", blocks: received_chain}) do
    latest_block_held = Chain.latest_block()
    [latest_block_received | _] = received_chain

    cond do
      latest_block_held.index >= latest_block_received.index ->
        Logger.info fn -> "received blockchain is no longer, doing nothing" end
        :ok
      latest_block_held.hash == latest_block_received.previous_hash ->
        Logger.info fn -> "adding new block" end
        :ok = Chain.add_block(latest_block_received)
        :ok = Mining.block_mined(latest_block_received)
        broadcast_new_block(latest_block_received)
        :ok
      length(received_chain) == 1 ->
        Logger.info fn -> "asking for all blocks" end
        response =
          Payload.query_all()
          |> Payload.encode!()
        {:ok, response}
      true ->
        Logger.info fn -> "replacing my chain" end
        Chain.replace_chain(received_chain)
    end
  end

  defp handle_payload(%Payload{type: "mining_request", data: data} = payload) do
    case Mining.mine(data) do
      :ok ->
        Logger.info fn -> "received data to be mined" end
        broadcast_mining_request(data)
        :ok
      :already_in_pool ->
        :ok
    end
  end

  defp handle_payload(_) do
    {:error, :unknown_type}
  end

  # sending

  def broadcast_new_block(%Block{} = block) do
    Logger.info fn -> "broadcasting new block" end
    [block]
    |> Payload.response_blockchain()
    |> Payload.encode!()
    |> Server.broadcast()
  end

  def broadcast_mining_request(data) do
    Logger.info fn -> "broadcasting mining request" end
    data
    |> Payload.mining_request()
    |> Payload.encode!()
    |> Server.broadcast()
  end
end
