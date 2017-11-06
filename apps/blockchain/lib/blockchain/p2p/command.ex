require Logger

defmodule Blockchain.P2P.Command do
  @moduledoc "TCP server commands"

  alias Blockchain.{Chain, Block, P2P.Payload, P2P.Server, Mempool}

  # reception

  @spec handle(String.t()) :: :ok | {:ok, String.t()} | {:error, String.t()}
  def handle(data) do
    case Payload.decode(data) do
      {:ok, payload} ->
        handle_payload(payload)

      {:error, _reason} = err ->
        err
    end
  end

  @spec handle_payload(%Payload{type: String.t()}) :: {:ok, String.t()}
  defp handle_payload(%Payload{type: "ping"}) do
    {:ok, "pong"}
  end

  @spec handle_payload(%Payload{type: String.t()}) :: {:ok, String.t()}
  defp handle_payload(%Payload{type: "query_latest"}) do
    Logger.info(fn -> "asking for latest block" end)

    response =
      [Chain.latest_block()]
      |> Payload.response_blockchain()
      |> Payload.encode!()

    {:ok, response}
  end

  @spec handle_payload(%Payload{type: String.t()}) :: {:ok, String.t()}
  defp handle_payload(%Payload{type: "query_all"}) do
    Logger.info(fn -> "asking for all blocks" end)

    response =
      Chain.all_blocks()
      |> Payload.response_blockchain()
      |> Payload.encode!()

    {:ok, response}
  end

  @spec handle_payload(%Payload{type: String.t(), blocks: [%Block{}]}) ::
          :ok | {:ok, String.t()} | {:error, String.t()}
  defp handle_payload(%Payload{type: "response_blockchain", blocks: received_chain}) do
    latest_block_held = Chain.latest_block()
    [latest_block_received | _] = received_chain

    cond do
      latest_block_held.index >= latest_block_received.index ->
        Logger.info(fn -> "received blockchain is no longer, doing nothing" end)
        :ok

      latest_block_held.hash == latest_block_received.previous_hash ->
        Logger.info(fn -> "adding new block" end)
        add_block(latest_block_received)
        :ok

      length(received_chain) == 1 ->
        Logger.info(fn -> "asking for all blocks" end)

        response =
          Payload.query_all()
          |> Payload.encode!()

        {:ok, response}

      true ->
        Logger.info(fn -> "replacing my chain" end)
        Chain.replace_chain(received_chain)
    end
  end

  @spec handle_payload(%Payload{type: String.t(), data: any()}) :: :ok
  defp handle_payload(%Payload{type: "mining_request", data: data}) do
    case Mempool.add(data) do
      :ok ->
        Logger.info(fn -> "received data to mine" end)
        broadcast_mining_request(data)
        :ok

      {:error, _reason} ->
        # block is already in mining pool, or BlockData.verify failed
        :ok
    end
  end

  @spec handle_payload(any()) :: {:error, :unknown_type}
  defp handle_payload(_) do
    {:error, :unknown_type}
  end

  @spec add_block(%Block{}) :: :ok
  defp add_block(%Block{} = block) do
    # notify mining pool to stop working on this block
    with :ok <- Chain.add_block(block),
         :ok <- Mempool.block_mined(block) do
      broadcast_new_block(block)
    else
      {:error, _reason} ->
        # block is invalid just ignoring it
        :ok
    end
  end

  # sending
  @spec broadcast_new_block(%Block{}) :: [:ok]
  def broadcast_new_block(%Block{} = block) do
    Logger.info(fn -> "broadcasting new block" end)

    [block]
    |> Payload.response_blockchain()
    |> Payload.encode!()
    |> Server.broadcast()
  end

  @spec broadcast_mining_request(any()) :: :ok | {:error, String.t()}
  def broadcast_mining_request(data) do
    Logger.info(fn -> "broadcasting mining request" end)

    data
    |> Payload.mining_request()
    |> Payload.encode!()
    |> Server.broadcast()

    Mempool.add(data)
  end
end