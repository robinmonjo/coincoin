defmodule Coincoin.Blockchain.Test.P2P.CommandTest do
  use ExUnit.Case
  import Coincoin.Blockchain.Test.Fixtures

  alias Coincoin.Blockchain.{Chain, Block, P2P.Command, P2P.Payload}

  defp call(%Payload{} = p) do
    p
    |> Payload.encode!()
    |> Command.handle()
  end

  test "handle payload ping" do
    assert call(Payload.ping()) == {:ok, "pong"}
  end

  test "handle payload query_latest" do
    blockchain = mock_blockchain(3)
    :ok = Chain.replace_chain(blockchain)

    expected =
      [Chain.latest_block()]
      |> Payload.response_blockchain()
      |> Payload.encode!()

    assert call(Payload.query_latest()) == {:ok, expected}
  end

  test "handle payload query_all" do
    blockchain = mock_blockchain(3)
    :ok = Chain.replace_chain(blockchain)

    expected =
      Chain.all_blocks()
      |> Payload.response_blockchain()
      |> Payload.encode!()

    assert call(Payload.query_all()) == {:ok, expected}
  end

  test "handle payload blockchain_response" do
    remote_chain = mock_blockchain(15)

    # receiving a new block that can be added
    [block | chain] = remote_chain
    :ok = Chain.replace_chain(chain)

    assert call(Payload.response_blockchain([block])) == :ok
    assert Chain.all_blocks() == remote_chain

    # receiving a smaller blockchain
    :ok = Chain.replace_chain(remote_chain)
    [_ | chain] = remote_chain

    assert call(Payload.response_blockchain(chain)) == :ok
    assert Chain.all_blocks() == remote_chain

    # receiving a longer chain
    :ok = Chain.replace_chain([Block.genesis_block()])
    assert call(Payload.response_blockchain(remote_chain)) == :ok
    assert Chain.all_blocks() == remote_chain

    # receiving one block higher than my last block
    :ok = Chain.replace_chain([Block.genesis_block()])
    [latest_block | _] = remote_chain

    expected =
      Payload.query_all()
      |> Payload.encode!()

    assert call(Payload.response_blockchain([latest_block])) == {:ok, expected}
    assert Chain.all_blocks() == [Block.genesis_block()]
  end

  test "handle payload mining_request" do
    assert call(Payload.mining_request("data")) == :ok
  end
end
