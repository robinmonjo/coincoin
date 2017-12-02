defmodule Token.Wallet do
  @moduledoc """
  Structure that represents a wallet and functions to work on wallet
  """

  alias Token.{Wallet, Crypto, Ledger, Transaction}

  @type t :: %__MODULE__{
          address: String.t(),
          public_key: String.t(),
          private_key: String.t()
        }

  defstruct [
    :address,
    :public_key,
    :private_key
  ]

  @spec generate() :: t
  def generate do
    {pub, priv} = Crypto.generate_key_pair()

    %Wallet{
      address: Crypto.public_key_hash(pub),
      public_key: pub,
      private_key: priv
    }
  end

  @spec sign(String.t(), t) :: String.t()
  def sign(msg, %Wallet{private_key: key}) do
    Crypto.sign(key, msg)
  end

  @spec verify(String.t(), String.t(), t) :: boolean
  def verify(msg, signature, %Wallet{public_key: key}) do
    Crypto.verify_signature(key, msg, signature)
  end

  @spec balance(t) :: integer
  def balance(%Wallet{} = wallet) do
    wallet
    |> Ledger.unspent_outputs()
    |> unspent_outputs_sum()
  end

  @spec send(integer, String.t(), t) :: :ok | {:error, String.t()}
  def send(value, recipient, %Wallet{} = wallet) do
    with {:ok, unspent_outputs} <- unspent_outputs_for_value(value, wallet),
         inputs <- prepare_inputs(unspent_outputs),
         outputs <- [[recipient, value]],
         outputs <- add_change_output(value, outputs, unspent_outputs, wallet) do
      wallet
      |> Transaction.new_transaction(inputs, outputs)
      |> Ledger.write()
    end
  end

  @spec add_change_output(integer, [Transaction.output()], [Ledger.output()], t) :: [
          Transaction.output()
        ]
  defp add_change_output(value, outputs, unspent_outputs, %Wallet{} = wallet) do
    outputs_sum = unspent_outputs_sum(unspent_outputs)

    if outputs_sum > value do
      [[wallet.address, outputs_sum - value] | outputs]
    else
      outputs
    end
  end

  @spec prepare_inputs([Ledger.output()]) :: [Transaction.input()]
  defp prepare_inputs(outputs) do
    for {tx_hash, index, _value} <- outputs, do: [tx_hash, index]
  end

  @spec unspent_outputs_for_value(integer, t) ::
          {:ok, [Transaction.output()]} | {:error, String.t()}
  defp unspent_outputs_for_value(target_value, %Wallet{} = wallet) do
    wallet
    |> Ledger.unspent_outputs()
    |> Enum.sort(fn {_, _, v1}, {_, _, v2} -> v1 <= v2 end)
    |> select_outputs(target_value, [])
  end

  @spec select_outputs([Ledger.output()], integer, [Ledger.output()]) ::
          {:ok, [Transaction.output()]} | {:error, atom()}
  defp select_outputs(_, value, outputs) when value <= 0, do: {:ok, outputs}
  defp select_outputs([], _value, _outputs), do: {:error, :not_enough_coins}

  defp select_outputs([{_, _, v} = output | remaining], value, outputs) do
    select_outputs(remaining, value - v, [output | outputs])
  end

  @spec unspent_outputs_sum([Ledger.output()]) :: integer
  defp unspent_outputs_sum(unspent_outputs) do
    Enum.reduce(unspent_outputs, 0, fn {_, _, value}, acc -> acc + value end)
  end
end
