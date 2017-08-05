defmodule Token.Transaction do

  alias Token.{Wallet, Transaction, Crypto}

  defstruct [
    :hash,
    :inputs, # an array of tuple of the form [{previous_tx_hash, output_index}]
    :public_key,
    :signature,
    :outputs # an array of tuple of the form [{recipient, value}]
  ]

  def new_transaction(%Wallet{} = wallet, inputs, outputs) do
    tx = %Transaction{
      inputs: inputs,
      public_key: wallet.public_key,
      outputs: outputs
    }
    sig =
      tx
      |> signing_string()
      |> Wallet.sign(wallet)
    signed_tx = %{tx | signature: sig}
    %{signed_tx | hash: compute_hash(signed_tx)}
  end

  def new_coinbase_transaction(outputs) do
    tx = %Transaction{
      outputs: outputs,
      inputs: [{"0", 0}] # coinbase transaction identifier, miner will have to accept this
    }
    %{tx | hash: compute_hash(tx)}
  end

  def signing_string(%Transaction{} = tx) do
    s = Enum.reduce(tx.inputs ++ tx.outputs, "", fn({str, int}, acc) ->
      acc <> str <> Integer.to_string(int)
    end)
    "#{s}#{tx.public_key}"
  end

  defp compute_hash(%Transaction{} = tx) do
    "#{signing_string(tx)}#{tx.signature}"
    |> Crypto.hash(:sha256)
    |> Base.encode16()
  end
end
