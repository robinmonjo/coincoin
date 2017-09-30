defmodule Token.Transaction.VerifyTest do
  use ExUnit.Case
  import Token.Fixtures

  alias Token.{Transaction, Transaction.Verify, Ledger, Crypto, Wallet}

  setup do
    {:ok, mock_ledger()}
  end

  test "transaction can't be added if a transaction with the same hash exists" do
    transactions = Ledger.all_transactions()
    tx = Enum.at(transactions, 3)
    assert Verify.verify_transaction(tx, Ledger.find_func) == {:error, "transaction already exists"}
  end

  test "transaction inputs must refer to an existing transaction", %{bob: bob, alice: alice} do
    bob_unspent_transactions = Ledger.unspent_outputs(bob)
    # bob should have 2 unspent transactions
    [utx | _] = bob_unspent_transactions
    {tx_hash, idx, _} = utx

    inputs = [[tx_hash, idx]]
    outputs = [[alice.address, 3]]
    tx = Transaction.new_transaction(bob, inputs, outputs)

    assert Verify.verify_transaction(tx, Ledger.find_func) == :ok

    unknown_hash =
      "unknown"
      |> Crypto.hash(:sha256)
      |> Base.encode16()

    inputs = [[unknown_hash, idx]]
    tx = Transaction.new_transaction(bob, inputs, outputs)

    assert Verify.verify_transaction(tx, Ledger.find_func) == {:error, "input doesn't exist"}
  end

  test "transaction inputs must refer to an unspent transaction", %{bob: bob, alice: alice} do
    last_tx = Enum.at(Ledger.all_transactions, -1)

    # in mock_ledger, bob did the last transaction
    # he shouldn't be able to do another transaction using the same inputs
    inputs = last_tx.inputs
    outputs = [[alice.address, 3]]
    tx = Transaction.new_transaction(bob, inputs, outputs)
    assert Verify.verify_transaction(tx, Ledger.find_func) == {:error, "input already spent"}
  end

  test "transaction inputs sum must be superior or equal to transaction output sum", %{bob: bob, alice: alice, joe: joe} do
    bob_unspent_transactions = Ledger.unspent_outputs(bob)
    available = Wallet.balance(bob)

    inputs = Enum.reduce(bob_unspent_transactions, [], fn({tx_hash, idx, _}, acc) ->
      [[tx_hash, idx] | acc]
    end)

    outputs = [[alice.address, available]]
    tx = Transaction.new_transaction(bob, inputs, outputs)
    assert Verify.verify_transaction(tx, Ledger.find_func) == :ok

    outputs = [[joe.address, 1] | outputs]
    tx = Transaction.new_transaction(bob, inputs, outputs)
    assert Verify.verify_transaction(tx, Ledger.find_func) == {:error, "input sum below output sum"}
  end

  test "transaction inputs must be owned by the public key" do

  end

  test "transaction signature must be verified by the public key" do

  end
end
