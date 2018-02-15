defmodule Token.TransactionTest do
  use ExUnit.Case, async: true

  alias Token.{Transaction, Wallet, Crypto}

  setup do
    {:ok,
     %{
       alice: Wallet.generate(),
       bob: Wallet.generate()
     }}
  end

  test "create transaction", %{alice: alice, bob: bob} do
    inputs = [["hash", 0]]
    outputs = [[bob.address, 20]]
    tx = Transaction.new_transaction(alice, inputs, outputs)

    assert tx.inputs == inputs
    assert tx.outputs == outputs
    assert tx.public_key == alice.public_key
    assert byte_size(tx.hash) == 64

    signing_string = Transaction.signing_string(tx)

    assert Crypto.verify_signature(alice.public_key, signing_string, tx.signature)
  end

  test "create coinbase transaction", %{alice: alice} do
    outputs = [[alice.address, 20]]
    tx = Transaction.new_coinbase_transaction(outputs)

    assert tx.inputs == [["0", 0]]
    assert tx.outputs == outputs
    assert tx.public_key == nil
    assert tx.signature == nil
    assert byte_size(tx.hash) == 64
  end
end
