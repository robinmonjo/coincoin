defmodule Coincoin.Token.Transaction.Verify do
  @moduledoc """
  Holds the logic for verifying a transaction.
  Inspired by https://en.bitcoin.it/wiki/Protocol_rules
  """

  alias Coincoin.Token.{Crypto, Transaction}

  @typep error :: {:error, atom()}
  @typep return :: :ok | error
  @typep find_func :: Coincoin.Token.Ledger.find_func()

  @spec verify_transaction(Transaction.t(), find_func) :: return
  def verify_transaction(%Transaction{} = transaction, find_in_ledger) do
    with :ok <- ensure_format(transaction),
         :ok <- ensure_doesnt_already_exist(transaction, find_in_ledger),
         {:ok, used_outputs} <- ensure_input_transactions_exist(transaction, find_in_ledger),
         :ok <- ensure_inputs_not_already_spent(transaction, find_in_ledger),
         :ok <- ensure_inputs_sum_superior_to_outputs_sum(transaction, used_outputs),
         :ok <- ensure_inputs_ownership(transaction, used_outputs),
         do: ensure_public_key_ownership(transaction)
  end

  @spec ensure_format(Transaction.t()) :: return
  defp ensure_format(%Transaction{} = transaction) do
    cond do
      !sha256_string?(transaction.hash) -> {:error, :invalid_hash_format}
      length(transaction.inputs) <= 0 -> {:error, :no_input}
      length(transaction.outputs) <= 0 -> {:error, :no_output}
      !valid_inputs_format?(transaction.inputs) -> {:error, :invalid_input}
      !valid_outputs_format?(transaction.outputs) -> {:error, :invalid_output}
      true -> :ok
    end
  end

  defp sha256_string?(str), do: byte_size(str) == 64
  defp reepdm160_string?(str), do: byte_size(str) == 40

  defp valid_inputs_format?([]), do: true

  defp valid_inputs_format?([[transaction_reference, output_index] | remaining]) do
    if sha256_string?(transaction_reference) && output_index >= 0 do
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
  defp ensure_doesnt_already_exist(%Transaction{} = transaction, find_in_ledger) do
    case find_in_ledger.(&(&1.hash == transaction.hash)) do
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

  defp find_inputs([[previous_reference, index] | remaining], find_in_ledger, acc) do
    with %Transaction{} = previous_transaction <- find_in_ledger.(&(&1.hash == previous_reference)),
         {:ok, [_recipient, _value] = input_reference} <- Enum.fetch(previous_transaction.outputs, index) do
      find_inputs(remaining, find_in_ledger, [input_reference | acc])
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
    find_in_ledger.(fn transaction ->
      Enum.find(transaction.inputs, &(&1 == input))
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
  defp ensure_inputs_ownership(%Transaction{public_key: public_key}, used_outputs) do
    public_key_hash = Crypto.public_key_hash(public_key)
    ensure_inputs_public_key_hash(used_outputs, public_key_hash)
  end

  @spec ensure_inputs_public_key_hash([Transaction.input()], String.t()) :: return
  defp ensure_inputs_public_key_hash([], _), do: :ok

  defp ensure_inputs_public_key_hash([[recipient, _value] | remaining], public_key_hash) do
    if recipient == public_key_hash do
      ensure_inputs_public_key_hash(remaining, public_key_hash)
    else
      {:error, :not_input_owner}
    end
  end

  @spec ensure_public_key_ownership(Transaction.t()) :: return
  defp ensure_public_key_ownership(%Transaction{public_key: public_key, signature: signature} = transaction) do
    signing_string = Transaction.signing_string(transaction)

    if Crypto.verify_signature(public_key, signing_string, signature) do
      :ok
    else
      {:error, :signature_mismatch}
    end
  end
end
