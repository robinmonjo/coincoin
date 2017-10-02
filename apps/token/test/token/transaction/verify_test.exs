defmodule Token.Transaction.VerifyTest do
  use ExUnit.Case, async: true
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
    bob_unspent_outputs = Ledger.unspent_outputs(bob)
    # bob should have 2 unspent transactions
    [utx | _] = bob_unspent_outputs
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
    bob_unspent_outputs = Ledger.unspent_outputs(bob)
    available = Wallet.balance(bob)

    inputs = Enum.reduce(bob_unspent_outputs, [], fn({tx_hash, idx, _}, acc) ->
      [[tx_hash, idx] | acc]
    end)

    outputs = [[alice.address, available]]
    tx = Transaction.new_transaction(bob, inputs, outputs)
    assert Verify.verify_transaction(tx, Ledger.find_func) == :ok

    outputs = [[joe.address, 1] | outputs]
    tx = Transaction.new_transaction(bob, inputs, outputs)
    assert Verify.verify_transaction(tx, Ledger.find_func) == {:error, "input sum below output sum"}
  end

  test "transaction inputs must be owned by the public key", %{bob: bob, alice: alice, joe: joe} do
    # what if bob tries to to spend alice's token ??
    alice_unspent_outputs = Ledger.unspent_outputs(alice)
    inputs = Enum.reduce(alice_unspent_outputs, [], fn({tx_hash, idx, _}, acc) ->
      [[tx_hash, idx] | acc]
    end)

    outputs = [[joe.address, 10]]
    tx = Transaction.new_transaction(bob, inputs, outputs)
    assert Verify.verify_transaction(tx, Ledger.find_func) ==
      {:error, "recipient in input doesn't match transaction public key"}
  end

  test "transaction signature must be verified by the public key", %{bob: bob, alice: alice, joe: joe} do
    # what if bob intercepts a transaction between alice and joe and modify the output
    # so tokens are transfered to himself ?
    alice_unspent_outputs = Ledger.unspent_outputs(alice)
    inputs = Enum.reduce(alice_unspent_outputs, [], fn({tx_hash, idx, _}, acc) ->
      [[tx_hash, idx] | acc]
    end)

    outputs = [[joe.address, 10]]
    tx = Transaction.new_transaction(alice, inputs, outputs)
    assert Verify.verify_transaction(tx, Ledger.find_func) == :ok

    altered_tx = %{tx | outputs: [[bob.address, 10]]}
    assert Verify.verify_transaction(altered_tx, Ledger.find_func) ==
      {:error, "unable to verify signature, public key is not associated to the signing key or the transaction was altered"}
  end
end
