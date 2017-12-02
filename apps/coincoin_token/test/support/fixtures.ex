defmodule Coincoin.Token.Test.Fixtures do
  @moduledoc "Test helpers"

  alias Coincoin.Token.{Wallet, Transaction, Ledger, Test.Blockchain}

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
    :ok = Blockchain.clear()

    # create wallets for each participants
    alice = Wallet.generate_wallet()
    bob = Wallet.generate_wallet()
    joe = Wallet.generate_wallet()

    # initial founds
    alice_utx = Transaction.new_coinbase_transaction([[alice.address, 50]])
    :ok = Ledger.write(alice_utx)
    bob_utx = Transaction.new_coinbase_transaction([[bob.address, 20]])
    :ok = Ledger.write(bob_utx)

    # first transaction
    inputs = [[alice_utx.hash, 0]]
    outputs = [[bob.address, 20], [joe.address, 10], [alice.address, 20]]
    tx1 = Transaction.new_transaction(alice, inputs, outputs)
    :ok = Ledger.write(tx1)

    # second transaction
    inputs = [[tx1.hash, 0]]
    outputs = [[joe.address, 5], [alice.address, 7], [bob.address, 8]]
    tx2 = Transaction.new_transaction(bob, inputs, outputs)
    :ok = Ledger.write(tx2)

    # third transaction
    inputs = [[tx1.hash, 1]]
    outputs = [[alice.address, 6], [joe.address, 4]]
    tx3 = Transaction.new_transaction(joe, inputs, outputs)
    :ok = Ledger.write(tx3)

    # fourth transaction
    inputs = [[tx2.hash, 2]]
    outputs = [[alice.address, 3], [joe.address, 1], [bob.address, 4]]
    tx4 = Transaction.new_transaction(bob, inputs, outputs)
    :ok = Ledger.write(tx4)

    %{alice: alice, bob: bob, joe: joe}
  end
end
