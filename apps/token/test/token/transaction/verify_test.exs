defmodule Token.Transaction.VerifyTest do
  use ExUnit.Case
  import Token.Fixtures

  alias Token.{Transaction, Transaction.Verify, Ledger, Crypto}

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
    invalid_tx = Transaction.new_transaction(bob, inputs, outputs)

    assert Verify.verify_transaction(invalid_tx, Ledger.find_func) == {:error, "input doesn't exist"}
  end

  test "transaction inputs must refer to an unspent transaction" do

  end

  test "transaction inputs sum must be superior or equal to transaction output sum" do

  end

  test "transaction inputs must be owned by the public key" do

  end

  test "transaction signature must be verified by the public key" do

  end
end
