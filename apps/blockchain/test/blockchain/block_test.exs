defmodule Blockchain.BlockTest do
  use ExUnit.Case, async: true

  alias Blockchain.{Block, Chain}

  test "generate next block" do
    data = "some data"
    b = Block.generate_next_block("some data")
    latest_block = Chain.latest_block()
    assert b.previous_hash == latest_block.hash
    assert b.data == data
    assert b.index == latest_block.index + 1
  end
end
