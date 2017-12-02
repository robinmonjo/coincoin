defmodule Coincoin.Token do
  @moduledoc """
  Token system
  """

  alias Coincoin.Token.{MyWallet, Transaction, Ledger}

  defdelegate address, to: MyWallet
  defdelegate balance, to: MyWallet
  defdelegate send(amount, recipient), to: MyWallet

  @spec free_tokens(integer) :: :ok | {:error, String.t()}
  def free_tokens(amount) do
    utx = Transaction.new_coinbase_transaction([[address(), amount]])
    Ledger.write(utx)
  end
end
