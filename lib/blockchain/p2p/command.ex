require Logger

defmodule Blockchain.P2P.Command do
  @moduledoc "TCP server commands"

  alias Blockchain.{Chain, Block, P2P.Payload, P2P.Server}

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

  defp handle_payload(%Payload{type: "response_blockchain", data: received_chain}) do
    latest_block_held = Chain.latest_block()
    [latest_block_received | _] = received_chain

    cond do
      latest_block_held.index >= latest_block_received.index ->
        Logger.info fn -> "received blockchain is no longer, doing nothing" end
        :ok
      latest_block_held.hash == latest_block_received.previous_hash ->
        Logger.info fn -> "adding new block" end
        :ok = Chain.add_block(latest_block_received)
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

  defp handle_payload(_) do
    {:error, :unknown_type}
  end

  def broadcast_new_block(%Block{} = block) do
    Logger.info fn -> "broadcasting new block" end
    Payload.response_blockchain([block])
    |> Payload.encode!()
    |> Server.broadcast()
  end
end
