defmodule Token.TransactionTest do
  use ExUnit.Case

  alias Token.{Wallet, Transaction, Transaction.Verify}

  test "transaction integration" do
    # create two actors
    alice = Wallet.generate_wallet()
    bob = Wallet.generate_wallet()

    # give alice some free token
    alice_utx = Transaction.new_coinbase_transaction([{alice.address, 50}])

    ledger = [alice_utx] # this is added without verification

    # make the transaction
    tx = Transaction.new_transaction(alice, [{alice_utx.hash, 0}], [{bob.address, 20}])

    # verify the transaction
    assert :ok = Verify.verify_transaction(tx, find_in_ledger_fn(ledger))

    # add it to the ledger
    ledger = [tx | ledger]

    # new transaction from bob to alice
    tx2 = Transaction.new_transaction(bob, [{tx.hash, 0}], [{alice.address, 10}])

    assert :ok = Verify.verify_transaction(tx2, find_in_ledger_fn(ledger))

    ledger = [tx2 | ledger]

    tx3 = Transaction.new_transaction(bob, [{tx.hash, 0}], [{alice.address, 15}])

    assert {:error, "input already spent"} = Verify.verify_transaction(tx3, find_in_ledger_fn(ledger))
  end

  defp find_in_ledger_fn(ledger) do
    fn(f) ->
      Enum.find(ledger, &(f.(&1)))
    end
  end
end
