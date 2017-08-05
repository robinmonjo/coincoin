defmodule Token.TransactionTest do
  use ExUnit.Case

  alias Token.{Wallet, Transaction}

  test "transaction" do
    # create two actors
    alice = Wallet.generate_wallet()
    bob = Wallet.generate_wallet()

    # give alice some free token
    alice_utx = Transaction.new_coinbase_transaction([{alice.address, 50}])
    IO.puts "-------- UTXO"
    IO.inspect alice_utx
    blockchain = [alice_utx]

    # make the transaction
    tx = Transaction.new_transaction(alice, [{alice_utx.hash, 0}], [{bob.address, 20}])
    IO.puts "-------- TX"
    IO.inspect tx

    find_in_ledger = fn(f) ->
      Enum.find(blockchain, &(f.(&1)))
    end

    #tx = %{tx | public_key: tx.public_key <> "1"}

    res = Transaction.Verify.verify_transaction(tx, find_in_ledger)
    IO.puts "-------- verification"
    IO.inspect(res)

    blockchain = [tx | blockchain]

    find_in_ledger = fn(f) ->
      Enum.find(blockchain, &(f.(&1)))
    end

    tx2 = Transaction.new_transaction(bob, [{tx.hash, 0}], [{alice.address, 10}])
    IO.puts "-------- TX2"
    IO.inspect(tx2)

    res = Transaction.Verify.verify_transaction(tx2, find_in_ledger)
    IO.puts "-------- verification"
    IO.inspect(res)

    blockchain = [tx2 | blockchain]

    find_in_ledger = fn(f) ->
      Enum.find(blockchain, &(f.(&1)))
    end

    tx3 = Transaction.new_transaction(bob, [{tx.hash, 0}], [{alice.address, 15}])
    IO.puts "-------- TX3"
    IO.inspect(tx3)

    res = Transaction.Verify.verify_transaction(tx3, find_in_ledger)
    IO.puts "-------- verification"
    IO.inspect(res)


    # tx = Tx.add_input(tx, alice, alice_utx.hash, 0)
    # IO.puts "-------- WITH INPUT"
    # IO.inspect tx
    # tx = Tx.sign_tx(tx, alice)
    # IO.puts "-------- SIGNED"
    # IO.inspect tx
    #
    # transactionf finder
    # tx_finder = fn(hash) ->
    #   Enum.find(blockchain, &(&1.hash == hash))
    # end
    #
    # tx = %{tx | signature: "30440220257DBB9072C10CA5F05B4C8794964B3AE98EB41CF65390933BDC19D991C9B28802202AC8ECC1CD5AEF9C63C530B91D2C3001BB95C9A5E20B88F2AF5FB6DA80C6F996"}
    #
    #
    # res = Txs.verify_tx(tx, tx_finder)
    # IO.inspect res



  end
end
