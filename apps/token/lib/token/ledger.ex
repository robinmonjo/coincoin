defmodule Token.Ledger do
  @moduledoc """
  Abstraction around the blockchain. Only module that interacts with the
  underlying blockchain
  """

  alias Token.{Ledger, Wallet, Transaction, Transaction.Verify}

  @blockchain Application.get_env(:token, :blockchain)

  # transactions are sent to the blockchain as raw maps
  defimpl Blockchain.Data, for: Map do
    def hash(map), do: Ledger.map_to_tx(map).hash

    def verify(map, chain) do
      tx = Ledger.map_to_tx(map)
      if tx.inputs == [["0", 0]] do
        # coinbase transaction are automatically validated
        :ok
      else
        Verify.verify_transaction(tx, Ledger.find_func(chain))
      end
    end
  end

  def write(%Transaction{} = tx) do
    tx
    |> Map.from_struct()
    |> @blockchain.add()
  end

  def all_transactions do
    reduce_while([], &({:cont, [&1 | &2]}))
  end

  def find_func, do: find_func(@blockchain.blocks())
  def find_func(chain) do
    fn(func) ->
      reduce_while(chain, nil, fn(%Transaction{} = tx, acc) ->
        if func.(tx), do: {:halt, tx}, else: {:cont, acc}
      end)
    end
  end

  def unspent_outputs(%Wallet{} = wallet) do
    inputs_set = inputs_set()
    Enum.reject(wallet_outputs(wallet), fn({tx_hash, output_index, _}) ->
      MapSet.member?(inputs_set, [tx_hash, output_index])
    end)
  end

  # returns all ledger inputs in a MapSet
  defp inputs_set do
    reduce_while(MapSet.new, fn(%Transaction{inputs: inputs}, set) ->
      {:cont, Enum.reduce(inputs, set, &(MapSet.put(&2, &1)))}
    end)
  end

  # returns all transaction sent to the given wallet format: [{tx_hash, output_idx, value}]
  defp wallet_outputs(%Wallet{address: address}) do
    reduce_while([], fn(%Transaction{hash: hash, outputs: outputs}, acc) ->
      indexed_outputs = Enum.with_index(outputs)
      {:cont, acc ++ Enum.reduce(indexed_outputs, [], fn({[recipient, value], index}, acc) ->
        if recipient == address do
          [{hash, index, value} | acc]
        else
          acc
        end
      end)}
    end)
  end

  defp reduce_while(acc, func), do: reduce_while(@blockchain.blocks(), acc, func)
  defp reduce_while(chain, acc, func) do
    Enum.reduce_while(chain, acc, fn(%{data: data}, acc) ->
      case data do
        data when is_map(data) ->
          func.(map_to_tx(data), acc)
        _ ->
          {:cont, acc}
      end
    end)
  end

  def map_to_tx(map) do
    map = Enum.reduce(map, %{}, fn({key, val}, acc) ->
      if is_atom(key) do
        Map.put(acc, key, val)
      else
        Map.put(acc, String.to_atom(key), val)
      end
    end)
    struct(%Transaction{}, map)
  end
end
