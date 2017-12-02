defmodule Coincoin.Token.Transaction do
  @moduledoc """
  Structure that represents a transaction and functions to work on transactions
  """

  alias Coincoin.Token.{Wallet, Transaction, Crypto}

  # this is not ideal but we can't define spec like [String.t(), integer]
  # we can't use tuple here as it will be serialized as lists
  @type input :: [String.t() | integer]
  @type output :: [String.t() | integer]

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
    transaction = %Transaction{
      inputs: inputs,
      public_key: wallet.public_key,
      outputs: outputs
    }

    signature =
      transaction
      |> signing_string()
      |> Wallet.sign(wallet)

    signed_transaction = %{transaction | signature: signature}
    %{signed_transaction | hash: compute_hash(signed_transaction)}
  end

  @spec new_coinbase_transaction([output]) :: t
  def new_coinbase_transaction(outputs) do
    transaction = %Transaction{
      outputs: outputs,
      # coinbase transaction not validated
      inputs: [["0", 0]]
    }

    %{transaction | hash: compute_hash(transaction)}
  end

  @spec signing_string(t) :: String.t()
  def signing_string(%Transaction{} = transaction) do
    s =
      Enum.reduce(transaction.inputs ++ transaction.outputs, "", fn [str, int], acc ->
        acc <> str <> Integer.to_string(int)
      end)

    # @TODO find meaningful name for `s`
    "#{s}#{transaction.public_key}"
  end

  @spec compute_hash(t) :: String.t()
  defp compute_hash(%Transaction{} = transaction) do
    "#{signing_string(transaction)}#{transaction.signature}"
    |> Crypto.hash(:sha256)
    |> Base.encode16()
  end
end
