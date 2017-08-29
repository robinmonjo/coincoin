defmodule Token.LedgerTest do
  use ExUnit.Case

  alias Token.{Ledger, Wallet, Fixtures}

  test "unspent outputs" do
    %{
      alice: alice,
      bob: bob,
      joe: joe,
      ledger: ledger
    } = Fixtures.mock_ledger()
    IO.inspect(ledger)

    IO.inspect(Ledger.unspent_outputs(alice, ledger))
  end
end
