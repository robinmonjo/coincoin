defmodule Token.Transaction.Verify do
  @moduledoc """
    Holds the logic for verifying a transaction.
    Inspired by https://en.bitcoin.it/wiki/Protocol_rules
  """

  alias Token.{Crypto, Transaction}

  @typep error :: {:error, atom()}
  @typep return :: :ok | error
  @typep find_func :: Token.Ledger.find_func()

  @spec verify_transaction(Transaction.t(), find_func) :: return
  def verify_transaction(%Transaction{} = tx, find_in_ledger) do
    with :ok <- ensure_format(tx),
         :ok <- ensure_doesnt_already_exist(tx, find_in_ledger),
         {:ok, used_outputs} <- ensure_input_transactions_exist(tx, find_in_ledger),
         :ok <- ensure_inputs_not_already_spent(tx, find_in_ledger),
         :ok <- ensure_inputs_sum_superior_to_outputs_sum(tx, used_outputs),
         :ok <- ensure_inputs_ownership(tx, used_outputs),
         do: ensure_public_key_ownership(tx)
  end

  @spec ensure_format(Transaction.t()) :: return
  defp ensure_format(%Transaction{} = tx) do
    cond do
      !sha256_string?(tx.hash) -> {:error, :invalid_hash_format}
      length(tx.inputs) <= 0 -> {:error, :no_input}
      length(tx.outputs) <= 0 -> {:error, :no_output}
      !valid_inputs_format?(tx.inputs) -> {:error, :invalid_input}
      !valid_outputs_format?(tx.outputs) -> {:error, :invalid_output}
      true -> :ok
    end
  end

  defp sha256_string?(str), do: byte_size(str) == 64
  defp reepdm160_string?(str), do: byte_size(str) == 40

  defp valid_inputs_format?([]), do: true

  defp valid_inputs_format?([[tx_ref, output_index] | remaining]) do
    if sha256_string?(tx_ref) && output_index >= 0 do
      valid_inputs_format?(remaining)
    else
      false
    end
  end

  defp valid_outputs_format?([]), do: true

  defp valid_outputs_format?([[recipient, amount] | remaining]) do
    if reepdm160_string?(recipient) && amount > 0 do
      valid_outputs_format?(remaining)
    else
      false
    end
  end

  @spec ensure_doesnt_already_exist(Transaction.t(), find_func) :: return
  defp ensure_doesnt_already_exist(%Transaction{} = tx, find_in_ledger) do
    case find_in_ledger.(&(&1.hash == tx.hash)) do
      nil -> :ok
      _ -> {:error, :transaction_already_exists}
    end
  end

  @spec ensure_input_transactions_exist(Transaction.t(), find_func) ::
          {:ok, [Transaction.input()]} | error
  defp ensure_input_transactions_exist(%Transaction{inputs: inputs}, find_in_ledger) do
    find_inputs(inputs, find_in_ledger, [])
  end

  @spec find_inputs([Transaction.input()], find_func, [Transaction.input()]) ::
          {:ok, [Transaction.input()]} | error
  defp find_inputs([], _, acc), do: {:ok, acc}

  defp find_inputs([[prev_ref, index] | remaining], find_in_ledger, acc) do
    with %Transaction{} = prev_tx <- find_in_ledger.(&(&1.hash == prev_ref)),
         {:ok, [_recipient, _value] = input_ref} <- Enum.fetch(prev_tx.outputs, index) do
      find_inputs(remaining, find_in_ledger, [input_ref | acc])
    else
      _ -> {:error, :input_not_found}
    end
  end

  @spec ensure_inputs_not_already_spent(Transaction.t() | [Transaction.input()], find_func) ::
          return
  defp ensure_inputs_not_already_spent(%Transaction{inputs: inputs}, find_in_ledger) do
    ensure_inputs_not_already_spent(inputs, find_in_ledger)
  end

  defp ensure_inputs_not_already_spent([], _), do: :ok

  defp ensure_inputs_not_already_spent([input | remaining], find_in_ledger) do
    case input_spent?(input, find_in_ledger) do
      true -> {:error, :input_already_spent}
      false -> ensure_inputs_not_already_spent(remaining, find_in_ledger)
    end
  end

  @spec input_spent?(Transaction.input(), find_func) :: boolean
  defp input_spent?(input, find_in_ledger) do
    find_in_ledger.(fn tx ->
      Enum.find(tx.inputs, &(&1 == input))
    end) != nil
  end

  @spec ensure_inputs_sum_superior_to_outputs_sum(Transaction.t(), [Transaction.output()]) ::
          return
  defp ensure_inputs_sum_superior_to_outputs_sum(%Transaction{outputs: outputs}, used_outputs) do
    inputs_sum = compute_sum(used_outputs)
    outputs_sum = compute_sum(outputs)

    if inputs_sum < outputs_sum do
      {:error, :input_sum_below_output_sum}
    else
      :ok
    end
  end

  @spec compute_sum([Transaction.input()]) :: integer
  defp compute_sum([]), do: 0

  defp compute_sum([[_recipient, value] | remaining]) do
    value + compute_sum(remaining)
  end

  @spec ensure_inputs_ownership(Transaction.t(), [Transaction.output()]) :: return
  defp ensure_inputs_ownership(%Transaction{public_key: pk}, used_outputs) do
    pkh = Crypto.public_key_hash(pk)
    ensure_inputs_public_key_hash(used_outputs, pkh)
  end

  @spec ensure_inputs_public_key_hash([Transaction.input()], String.t()) :: return
  defp ensure_inputs_public_key_hash([], _), do: :ok

  defp ensure_inputs_public_key_hash([[recipient, _value] | remaining], pkh) do
    if recipient == pkh do
      ensure_inputs_public_key_hash(remaining, pkh)
    else
      {:error, :not_input_owner}
    end
  end

  @spec ensure_public_key_ownership(Transaction.t()) :: return
  defp ensure_public_key_ownership(%Transaction{public_key: pk, signature: sig} = tx) do
    signing_string = Transaction.signing_string(tx)

    if Crypto.verify_signature(pk, signing_string, sig) do
      :ok
    else
      {:error, :signature_mismatch}
    end
  end
end
