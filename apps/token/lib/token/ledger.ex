defmodule Token.Ledger do
  @moduledoc """
  Abstraction around the blockchain
  """

  alias Token.{Wallet, Transaction}

  def unspent_outputs(%Wallet{} = wallet, ledger) do
    inputs_set = inputs_set(ledger)
    wallet_outputs = wallet_outputs(wallet, ledger)

    Enum.reject(wallet_outputs, fn({tx_hash, output_index, _}) ->
      MapSet.member?(inputs_set, {tx_hash, output_index})
    end)
  end

  # returns all ledger inputs in a MapSet
  defp inputs_set(ledger) do
    Enum.reduce(ledger, MapSet.new, fn(%Transaction{inputs: inputs}, set) ->
      Enum.reduce(inputs, set, &(MapSet.put(&2, &1)))
    end)
  end

  # returns all transaction sent to the given wallet format: [{tx_hash, output_idx, value}]
  defp wallet_outputs(%Wallet{address: address}, ledger) do
    Enum.reduce(ledger, [], fn(%Transaction{hash: hash, outputs: outputs}, acc) ->
      indexed_outputs = Enum.with_index(outputs)
      acc ++ Enum.reduce(indexed_outputs, [], fn({{recipient, value}, index}, acc) ->
        if recipient == address do
          [{hash, index, value} | acc]
        else
          acc
        end
      end)
    end)
  end
end
