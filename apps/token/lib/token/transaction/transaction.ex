defmodule Token.Transaction do
  @moduledoc """
  Structure that represents a transaction and functions to work on transactions
  """

  alias Token.{Wallet, Transaction, Crypto}

  @type input :: [String.t() | [integer | []]] | Enum.t()
  @type output :: [String.t() | [integer | []]] | Enum.t()

  @type t :: %__MODULE__{
          hash: String.t() | nil,
          inputs: [input],
          public_key: String.t() | nil,
          signature: String.t() | nil,
          outputs: [output]
        }

  defstruct [
    :hash,
    # a list of list of the form [[previous_tx_hash, output_index]]
    :inputs,
    :public_key,
    :signature,
    # a list of list of the form [[recipient, value]]
    :outputs
  ]

  @spec new_transaction(Wallet.t(), [input], [output]) :: t
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

  @spec new_coinbase_transaction([output]) :: t
  def new_coinbase_transaction(outputs) do
    tx = %Transaction{
      outputs: outputs,
      # coinbase transaction not validated
      inputs: [["0", 0]]
    }

    %{tx | hash: compute_hash(tx)}
  end

  @spec signing_string(t) :: String.t()
  def signing_string(%Transaction{} = tx) do
    s =
      Enum.reduce(tx.inputs ++ tx.outputs, "", fn [str, int], acc ->
        acc <> str <> Integer.to_string(int)
      end)

    "#{s}#{tx.public_key}"
  end

  @spec compute_hash(t) :: String.t()
  defp compute_hash(%Transaction{} = tx) do
    "#{signing_string(tx)}#{tx.signature}"
    |> Crypto.hash(:sha256)
    |> Base.encode16()
  end
end
