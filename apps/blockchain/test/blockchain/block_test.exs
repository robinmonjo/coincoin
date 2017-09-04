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

  test "perform proof of work" do
    b =
      "some data"
      |> Block.generate_next_block()
      |> Block.perform_proof_of_work()
    assert b.nounce != nil
    assert Block.verify_proof_of_work(b.hash)
  end

  test "verify proof of work" do
    assert Block.verify_proof_of_work("0000DA3553676AC53CC20564D8E956D03A08F7747823439FDE74ABF8E7EADF60")
    refute Block.verify_proof_of_work("1000DA3553676AC53CC20564D8E956D03A08F7747823439FDE74ABF8E7EADF60")
  end
end
