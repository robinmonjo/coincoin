require Logger

defmodule Blockchain.Op do
  alias Blockchain.{Chain, Block}

  def determine_action(received_chain) do
    latest_block_held = Chain.latest_block()
    {:ok, latest_block_received} = Enum.fetch(received_chain, -1)

    cond do
      latest_block_held.index > latest_block_received.index ->
        :nothing
      latest_block_held.hash == latest_block_received.previous_hash ->
        :append_block
      length(received_chain) == 1 ->
        :query_all_chain
      true ->
        :replace_chain
    end
  end
end
