defmodule Blockchain.P2P.CommandTest do
  use ExUnit.Case
  import Blockchain.Fixtures

  alias Blockchain.P2P.{Command, Payload}
  alias Blockchain.{Chain, Block}

  setup do
    :ok
  end

  test "handling blockchain response" do
    remote_chain = mock_blockchain(10)

    # receiving a new block that can be added
    [block | chain] = remote_chain
    assert Chain.replace_chain(chain) == :ok
    payload =
      Payload.response_blockchain([block])
      |> Payload.encode!()

    :ok = Command.handle(payload)
    assert Chain.all_blocks() == remote_chain

    # receiving a smaller blockchain
    assert Chain.replace_chain(remote_chain) == :ok
    [_ | chain] = remote_chain
    payload =
      Payload.response_blockchain(chain)
      |> Payload.encode!()
    :ok = Command.handle(payload)
    assert Chain.all_blocks() == remote_chain

    # receiving a longer chain
    assert Chain.replace_chain([Block.genesis_block()])
    payload =
      Payload.response_blockchain(remote_chain)
      |> Payload.encode!()
    :ok = Command.handle(payload)
    assert Chain.all_blocks() == remote_chain
  end
end
