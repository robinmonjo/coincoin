defmodule Token.Transaction do
  @moduledoc """
  Structure that represents a transaction and functions to work on transactions
  """

  alias Token.{Wallet, Transaction, Crypto}

  defstruct [
    :hash,
    # a list of list of the form [[previous_tx_hash, output_index]]
    :inputs,
    :public_key,
    :signature,
    # a list of list of the form [[recipient, value]]
    :outputs
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
      # coinbase transaction not validated
      inputs: [["0", 0]]
    }

    %{tx | hash: compute_hash(tx)}
  end

  def signing_string(%Transaction{} = tx) do
    s =
      Enum.reduce(tx.inputs ++ tx.outputs, "", fn [str, int], acc ->
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
