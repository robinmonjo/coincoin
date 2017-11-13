defmodule Token.MyWallet do
  @moduledoc """
  GenServer that stores the current wallet. Exposes high level APIs of Token.Wallet
  """
  use GenServer

  alias Token.Wallet

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, Wallet.generate_wallet()}
  end

  @spec address() :: String.t()
  def address, do: GenServer.call(__MODULE__, :address)

  @spec balance() :: integer
  def balance, do: GenServer.call(__MODULE__, :balance)

  @spec send(integer, String.t()) :: :ok | {:error, String.t()}
  def send(amount, recipient), do: GenServer.call(__MODULE__, {:send, amount, recipient})

  def handle_call(:address, _from, wallet), do: {:reply, wallet.address, wallet}
  def handle_call(:balance, _from, wallet), do: {:reply, Wallet.balance(wallet), wallet}

  def handle_call({:send, amount, recipient}, _from, wallet) do
    {:reply, Wallet.send(amount, recipient, wallet), wallet}
  end
end
