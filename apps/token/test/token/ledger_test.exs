defmodule Token.LedgerTest do
  use ExUnit.Case, async: false
  import Token.Fixtures

  alias Token.Ledger

  setup do
    {:ok, mock_ledger()}
  end

  test "find_func returns a function that can be used to search in the ledger" do
    transactions = Ledger.all_transactions()
    assert length(transactions) == 6
    tx_to_find = Enum.at(transactions, 4)
    found_tx = Ledger.find_func().(&(&1.hash == tx_to_find.hash))
    assert found_tx == tx_to_find
  end

  test "unspent outputs", %{alice: alice, bob: bob, joe: joe} do
    # see fixtures to see why
    assert [
      {_tx1_hash, 0, 3},
      {_tx2_hash, 0, 6},
      {_tx3_hash, 1, 7},
      {_tx4_hash, 2, 20}
    ] = Ledger.unspent_outputs(alice)

    assert [
      {_tx1_hash, 2, 4},
      {_tx2_hash, 0, 20}
    ] = Ledger.unspent_outputs(bob)

    assert [
      {_tx1_hash, 1, 1},
      {_tx2_hash, 1, 4},
      {_tx3_hash, 0, 5}
    ] = Ledger.unspent_outputs(joe)
  end
end
