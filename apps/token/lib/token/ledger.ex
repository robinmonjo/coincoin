defmodule Token.Ledger do
  @moduledoc """
  Abstraction around the blockchain. Only module that interacts with the
  underlying blockchain
  """

  alias Token.{Ledger, Wallet, Transaction, Transaction.Verify}

  defimpl Blockchain.BlockData, for: Transaction do
    def hash(tx), do: tx.hash

    def verify(tx, chain) do
      if tx.inputs == [["0", 0]] do
        # coinbase transaction are automatically validated
        :ok
      else
        Verify.verify_transaction(tx, Ledger.find_func(chain))
      end
    end
  end

  defp blockchain, do: Application.get_env(:token, :blockchain)

  def write(%Transaction{} = tx), do: blockchain().add(tx)

  def all_transactions do
    reduce_while([], &{:cont, [&1 | &2]})
  end

  def find_func, do: find_func(blockchain().blocks())

  def find_func(chain) do
    &reduce_while(chain, nil, fn %Transaction{} = tx, acc ->
      if &1.(tx), do: {:halt, tx}, else: {:cont, acc}
    end)
  end

  def unspent_outputs(%Wallet{} = wallet) do
    inputs_set = inputs_set()

    Enum.reject(wallet_outputs(wallet), fn {tx_hash, output_index, _} ->
      MapSet.member?(inputs_set, [tx_hash, output_index])
    end)
  end

  # returns all ledger inputs in a MapSet
  defp inputs_set do
    reduce_while(MapSet.new(), fn %Transaction{inputs: inputs}, set ->
      {:cont, Enum.reduce(inputs, set, &MapSet.put(&2, &1))}
    end)
  end

  # returns all transaction sent to the given wallet format: [{tx_hash, output_idx, value}]
  defp wallet_outputs(%Wallet{address: address}) do
    reduce_while([], fn %Transaction{} = tx, acc ->
      {:cont, acc ++ address_outputs(tx, address)}
    end)
  end

  # return all outputs in the given transaction where recipient corresponds to the given address
  # format: [{tx_hash, output_idx, value}]
  defp address_outputs(%Transaction{hash: hash, outputs: outputs}, address) do
    indexed_outputs = Enum.with_index(outputs)

    Enum.reduce(indexed_outputs, [], fn {[recipient, value], index}, acc ->
      if recipient == address do
        [{hash, index, value} | acc]
      else
        acc
      end
    end)
  end

  defp reduce_while(acc, func), do: reduce_while(blockchain().blocks(), acc, func)

  defp reduce_while(chain, acc, func) do
    Enum.reduce_while(chain, acc, fn %{data: data}, acc ->
      case data do
        %Transaction{} ->
          func.(data, acc)

        _ ->
          {:cont, acc}
      end
    end)
  end
end
