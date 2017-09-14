defmodule Token.Wallet do
  @moduledoc "Wallet module"

  alias Token.{Wallet, Crypto, Ledger, Transaction}

  defstruct [
    :address,
    :public_key,
    :private_key
  ]

  def generate_wallet do
    {pub, priv} = Crypto.generate_key_pair()
    %Wallet{
      address: Crypto.public_key_hash(pub),
      public_key: pub,
      private_key: priv
    }
  end

  def sign(msg, %Wallet{} = wallet) do
    Crypto.sign(wallet.private_key, msg)
  end

  def verify(msg, signature, %Wallet{} = wallet) do
    Crypto.verify_signature(wallet.public_key, msg, signature)
  end

  def balance(%Wallet{} = wallet) do
    wallet
    |> Ledger.unspent_outputs()
    |> unspent_outputs_sum()
  end

  def send(value, recipient, %Wallet{} = wallet) do
    with {:ok, unspent_outputs} <- select_outputs(value, wallet),
         inputs <- prepare_inputs(unspent_outputs),
         outputs <- [[recipient, value]],
         final_outputs <- add_change_output(value, outputs, unspent_outputs, wallet)
    do
      tx = Transaction.new_transaction(wallet, inputs, final_outputs)
      Ledger.write(tx)
    end
  end

  defp add_change_output(value, outputs, unspent_outputs, %Wallet{} = wallet) do
    outputs_sum = unspent_outputs_sum(unspent_outputs)
    if outputs_sum > value do
      [[wallet.address, outputs_sum - value] | outputs]
    else
      outputs
    end
  end

  defp prepare_inputs(outputs), do: prepare_inputs(outputs, [])
  defp prepare_inputs([], inputs), do: inputs
  defp prepare_inputs([{tx_hash, index, _value} | remaining], inputs) do
    prepare_inputs(remaining, [[tx_hash, index] | inputs])
  end

  defp select_outputs(target_value, %Wallet{} = wallet) do
    wallet
    |> Ledger.unspent_outputs()
    |> Enum.sort(fn({_, _, v1}, {_, _, v2}) -> v1 <= v2 end)
    |> select_outputs(target_value, [])
  end
  defp select_outputs(_, value, outputs) when value <= 0, do: {:ok, outputs}
  defp select_outputs([], _value, _outputs), do: {:error, "not enough coins"}
  defp select_outputs([{_, _, v} = output | remaining], value, outputs) do
    select_outputs(remaining, value - v, [output | outputs])
  end

  defp unspent_outputs_sum(unspent_outputs) do
    Enum.reduce(unspent_outputs, 0, fn({_, _, value}, acc) -> acc + value end)
  end
end
