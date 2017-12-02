defmodule Coincoin.Blockchain.Test.ChainTest do
  use ExUnit.Case, async: false
  import Coincoin.Blockchain.Test.Fixtures

  alias Coincoin.Blockchain.{Chain, Block}

  test "first block should be the genesis block" do
    b = Block.genesis_block()
    {:ok, first_block} = Enum.fetch(Chain.all_blocks(), -1)
    assert first_block == b
  end

  test "add a block if valid" do
    b =
      "some data"
      |> Block.generate_next_block()
      |> proof_of_work().compute()

    assert :ok = Chain.add_block(b)
  end

  test "should fail if block is invalid" do
    valid_block =
      "some data"
      |> Block.generate_next_block()
      |> proof_of_work().compute()

    invalid_block = %{valid_block | index: 1000}
    assert {:error, :invalid_block_index} = Chain.add_block(invalid_block)

    invalid_block = %{valid_block | previous_hash: "not the good previous hash"}
    assert {:error, :invalid_block_previous_hash} = Chain.add_block(invalid_block)

    invalid_block = %{valid_block | hash: "0#{valid_block.hash}"}
    assert {:error, :invalid_block_hash} = Chain.add_block(invalid_block)

    invalid_hash = "F#{String.slice(valid_block.hash, 1..-1)}"
    invalid_block = %{valid_block | hash: invalid_hash}
    assert {:error, :proof_of_work_not_verified} = Chain.add_block(invalid_block)
  end

  test "validate a blockchain" do
    invalid_genesis_block = %Block{
      index: 1,
      previous_hash: "0",
      timestamp: 1_465_154_705,
      data: "genesis block"
    }

    assert {:error, :no_genesis_block} = Chain.validate_chain([invalid_genesis_block])

    genesis_block = Block.genesis_block()
    chain = [genesis_block]

    invalid_next_block = %Block{
      index: 1,
      previous_hash: "wrong",
      timestamp: 1_465_154_706,
      data: "first block"
    }

    assert {:error, :invalid_block_previous_hash} =
             Chain.validate_chain([invalid_next_block | chain])

    assert Chain.validate_chain(mock_blockchain(3))
  end

  test "replace the blockchain" do
    new_chain = mock_blockchain(6)
    :ok = Chain.replace_chain(new_chain)
    assert Chain.all_blocks() == new_chain
  end

  defp proof_of_work, do: Application.fetch_env!(:coincoin_blockchain, :proof_of_work)
end
