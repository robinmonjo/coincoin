defmodule Token do
  @moduledoc """
  Token system
  """

  alias Token.{MyWallet, Transaction, Ledger}

  def address, do: MyWallet.address()

  def balance, do: MyWallet.balance()

  def send(amount, recipient), do: MyWallet.send(amount, recipient)

  def free_tokens(amount) do
    utx = Transaction.new_coinbase_transaction([[address(), amount]])
    Ledger.write(utx)
  end
end
