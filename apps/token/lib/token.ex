defmodule Token do
  @moduledoc """
  Token system
  """

  alias Token.{MyWallet, Transaction, Ledger}

  @spec address() :: String.t()
  def address, do: MyWallet.address()

  @spec balance() :: integer
  def balance, do: MyWallet.balance()

  @spec send(integer, String.t()) :: :ok | {:error, String.t()}
  def send(amount, recipient), do: MyWallet.send(amount, recipient)

  @spec free_tokens(integer) :: :ok | {:error, String.t()}
  def free_tokens(amount) do
    utx = Transaction.new_coinbase_transaction([[address(), amount]])
    Ledger.write(utx)
  end
end
