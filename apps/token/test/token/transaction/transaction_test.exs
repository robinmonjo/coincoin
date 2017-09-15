defmodule Token.TransactionTest do
  use ExUnit.Case, async: true

  alias Token.{Transaction, Wallet, Crypto}
  alias Blockchain.Data

  setup do
    {:ok, %{
      alice: Wallet.generate_wallet(),
      bob: Wallet.generate_wallet()
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

  test "Blockchain.Data implementation", %{alice: alice, bob: bob} do
    inputs = [["hash", 0]]
    outputs = [[bob.address, 20]]
    tx = Transaction.new_transaction(alice, inputs, outputs)
    assert Data.hash(tx) == tx.hash

    coinbase_tx = Transaction.new_coinbase_transaction(outputs)
    assert Data.verify(coinbase_tx, []) == :ok
  end
end
