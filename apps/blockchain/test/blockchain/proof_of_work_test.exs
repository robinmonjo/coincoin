defmodule Blockchain.ProofOfWorkTest do
  use ExUnit.Case, async: true

  alias Blockchain.{Block, ProofOfWork}

  test "compute" do
    b =
      "some data"
      |> Block.generate_next_block()
      |> ProofOfWork.compute()

    assert b.nonce != nil
    assert ProofOfWork.verify(b.hash)
  end

  test "verify" do
    hash = "0000DA3553676AC53CC20564D8E956D03A08F7747823439FDE74ABF8E7EADF60"
    {n, _} = Integer.parse(hash, 16)
    assert ProofOfWork.verify(hash, n + 1)
    refute ProofOfWork.verify(hash, n)
    refute ProofOfWork.verify(hash, n - 1)
  end
end
