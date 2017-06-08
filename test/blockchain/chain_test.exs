defmodule Blockchain.ChainTest do
  use ExUnit.Case, async: false

  alias Blockchain.{Chain, Block}

  setup do
    :ok
  end

  test "first block should be the genesis block" do
    b = Block.genesis_block()
    {:ok, first_block} = Enum.fetch(Chain.all_blocks(), -1)
    assert first_block == b
  end

  test "should add a block if valid" do
    valid_block = Block.generate_next_block("some data")
    assert :ok = Chain.add_block(valid_block)
  end

  test "should fail if block is invalid" do
    valid_block = Block.generate_next_block("some data")

    invalid_block = %{valid_block | index: 1000}
    assert {:error, "invalid index"} = Chain.add_block(invalid_block)

    invalid_block = %{valid_block | previous_hash: "not the good previous hash"}
    assert {:error, "invalid previous hash"} = Chain.add_block(invalid_block)

    invalid_block = %{valid_block | hash: "not the good hash"}
    assert {:error, "invalid block hash"} = Chain.add_block(invalid_block)
  end
end
