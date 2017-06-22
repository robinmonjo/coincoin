defmodule Blockchain.P2P.CommandTest do
  use ExUnit.Case
  import Blockchain.Fixtures

  alias Blockchain.{Chain, Block, P2P.Command, P2P.Payload}

  setup do
    :ok
  end

  test "handling blockchain response" do
    remote_chain = mock_blockchain(10)

    # receiving a new block that can be added
    [block | chain] = remote_chain
    assert Chain.replace_chain(chain) == :ok
    payload =
      [block]
      |> Payload.response_blockchain()
      |> Payload.encode!()

    :ok = Command.handle(payload)
    assert Chain.all_blocks() == remote_chain

    # receiving a smaller blockchain
    assert Chain.replace_chain(remote_chain) == :ok
    [_ | chain] = remote_chain
    payload =
      chain
      |> Payload.response_blockchain()
      |> Payload.encode!()
    :ok = Command.handle(payload)
    assert Chain.all_blocks() == remote_chain

    # receiving a longer chain
    assert Chain.replace_chain([Block.genesis_block()])
    payload =
      remote_chain
      |> Payload.response_blockchain()
      |> Payload.encode!()
    :ok = Command.handle(payload)
    assert Chain.all_blocks() == remote_chain
  end
end
