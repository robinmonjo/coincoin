defmodule Blockchain.ProofOfWorkTest do
  use ExUnit.Case, async: true

  alias Blockchain.{Block, ProofOfWork}

  test "compute" do
    b =
      "some data"
      |> Block.generate_next_block()
      |> ProofOfWork.compute()
    assert b.nounce != nil
    assert ProofOfWork.verify(b.hash)
  end

  test "verify" do
    assert ProofOfWork.verify("0000DA3553676AC53CC20564D8E956D03A08F7747823439FDE74ABF8E7EADF60")
    refute ProofOfWork.verify("1000DA3553676AC53CC20564D8E956D03A08F7747823439FDE74ABF8E7EADF60")
  end
end
