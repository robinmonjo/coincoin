defmodule Token.WalletTest do
  use ExUnit.Case

  alias Token.Wallet

  setup do
    w = Wallet.generate_wallet()
    {:ok, wallet: w}
  end

  test "generate a new wallet", %{wallet: w} do
    assert w.public_key != nil
    assert w.private_key != nil
    assert byte_size(w.address) == 40
  end

  test "sign and verify data", %{wallet: w} do
    data = "some data to sign"
    signature = Wallet.sign(w, data)
    assert Wallet.verify(w, data, signature)
  end

end
