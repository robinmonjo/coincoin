defmodule Token.Fixtures do
  @moduledoc "Test helpers"

  alias Blockchain.{Block}
  alias Token.{Wallet, Transaction, Transaction.Verify}

  # mock a ledger with 3 participants alice bob joe
  # scénario:
  #   - alice/utx(50) bob/utx(20) joe/0
  #   - tx1 = alice -> 20 -> bob
  #                 -> 10 -> joe
  #                 -> 20 -> alice
  #   - alice/tx1(20) bob/utx(20)+tx1(20) joe/tx1(10)
  #   - tx2 = bob -> 5 -> joe
  #               -> 7 -> alice
  #               -> 8 -> bob
  #   - alice/tx1(20)+tx2(7) bob/utx(20)+tx2(8) joe/tx1(10)+tx2(5)
  #   - tx3 = joe -> 6 -> alice
  #               -> 4 -> joe
  #   - alice/tx1(20)+tx2(7)+tx3(6) bob/utx(20)+tx2(8) joe/tx2(5)+tx3(4)
  #   - tx4 = bob -> 3 -> alice
  #               -> 1 -> joe
  #               -> 4 -> bob
  #   - alice/tx1(20)+tx2(7)+tx3(6)+tx4(3) bob/utx(20)+tx4(4) joe/tx2(5)+tx3(4)+tx4(1)

  def mock_ledger do
    # create wallets for each participants
    alice = Wallet.generate_wallet()
    bob = Wallet.generate_wallet()
    joe = Wallet.generate_wallet()

    # initial founds
    alice_utx = Transaction.new_coinbase_transaction([{alice.address, 50}])
    bob_utx = Transaction.new_coinbase_transaction([{bob.address, 20}])
    ledger = [alice_utx, bob_utx]

    # first transaction
    tx1 = Transaction.new_transaction(alice, [{alice_utx.hash, 0}], [{bob.address, 20}, {joe.address, 10}, {alice.address, 20}])
    :ok = Verify.verify_transaction(tx1, find_in_ledger_fn(ledger))
    ledger = [tx1 | ledger]

    # second transaction
    tx2 = Transaction.new_transaction(bob, [{tx1.hash, 0}], [{joe.address, 5}, {alice.address, 7}, {bob.address, 8}])
    :ok = Verify.verify_transaction(tx2, find_in_ledger_fn(ledger))
    ledger = [tx2 | ledger]

    # third transaction
    tx3 = Transaction.new_transaction(joe, [{tx1.hash, 1}], [{alice.address, 6}, {joe.address, 4}])
    :ok = Verify.verify_transaction(tx3, find_in_ledger_fn(ledger))
    ledger = [tx3 | ledger]

    # fourth transaction
    tx4 = Transaction.new_transaction(bob, [{tx2.hash, 2}], [{alice.address, 3}, {joe.address, 1}, {bob.address, 4}])
    :ok = Verify.verify_transaction(tx4, find_in_ledger_fn(ledger))
    ledger = [tx4 | ledger]

    %{alice: alice, bob: bob, joe: joe, ledger: ledger}
  end

  defp find_in_ledger_fn(ledger) do
    fn(f) ->
      Enum.find(ledger, &(f.(&1)))
    end
  end
end
