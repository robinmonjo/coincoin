defmodule Token.Transaction.Verify do
  @moduledoc """
    Holds the logic for verifying a transaction.
    Inspired by https://en.bitcoin.it/wiki/Protocol_rules
  """

  alias Token.{Crypto, Transaction}

  def verify_transaction(%Transaction{} = tx, find_in_ledger) do
    with :ok <- ensure_format(tx),
         :ok <- ensure_doesnt_already_exist(tx, find_in_ledger),
         {:ok, used_outputs} <- ensure_input_transactions_exist(tx, find_in_ledger),
         :ok <- ensure_inputs_not_already_spent(tx, find_in_ledger),
         :ok <- ensure_inputs_sum_superior_to_outputs_sum(tx, used_outputs),
         :ok <- ensure_inputs_ownership(tx, used_outputs),
         do: ensure_public_key_ownership(tx)
  end

  defp ensure_format(%Transaction{} = tx) do
    :ok # TODO: check the format of the transaction
  end

  defp ensure_doesnt_already_exist(%Transaction{} = tx, find_in_ledger) do
    case find_in_ledger.(&(&1.hash == tx.hash)) do
      nil -> :ok
      _ -> {:error, "tx already exists"}
    end
  end

  defp ensure_input_transactions_exist(%Transaction{inputs: inputs}, find_in_ledger) do
    ensure_input_transactions_exist(inputs, find_in_ledger, [])
  end
  defp ensure_input_transactions_exist([], _, acc), do: {:ok, acc}
  defp ensure_input_transactions_exist([{prev_ref, index} | remaining], find_in_ledger, acc) do
    with %Transaction{} = prev_tx <- find_in_ledger.(&(&1.hash == prev_ref)),
         {:ok, {_recipient, _value} = input_ref} <- Enum.fetch(prev_tx.outputs, index)
    do
      ensure_input_transactions_exist(remaining, find_in_ledger, [input_ref | acc])
    else
      _ -> {:error, "input doesn't exist"}
    end
  end

  defp ensure_inputs_not_already_spent(%Transaction{inputs: inputs}, find_in_ledger) do
    ensure_inputs_not_already_spent(inputs, find_in_ledger)
  end
  defp ensure_inputs_not_already_spent([], _), do: :ok
  defp ensure_inputs_not_already_spent([input | remaining], find_in_ledger) do
    case input_spent?(input, find_in_ledger) do
      true -> {:error, "input already spent"}
      false -> ensure_inputs_not_already_spent(remaining, find_in_ledger)
    end
  end

  defp input_spent?(input, find_in_ledger) do
    find_in_ledger.(fn(tx) ->
      Enum.find(tx.inputs, &(&1 == input))
    end) != nil
  end

  defp ensure_inputs_sum_superior_to_outputs_sum(%Transaction{outputs: outputs}, used_outputs) do
    inputs_sum = compute_sum(used_outputs)
    outputs_sum = compute_sum(outputs)
    cond do
      inputs_sum < outputs_sum -> {:error, "input sum below output sum"}
      true -> :ok
    end
  end

  defp compute_sum([]), do: 0
  defp compute_sum([{_recipient, value} | remaining]) do
    value + compute_sum(remaining)
  end

  defp ensure_inputs_ownership(%Transaction{public_key: pk}, used_outputs) do
    pkh = Crypto.public_key_hash(pk)
    ensure_inputs_ownership(used_outputs, pkh)
  end
  defp ensure_inputs_ownership([], _), do: :ok
  defp ensure_inputs_ownership([{recipient, _value} | remaining], pkh) do
    cond do
      recipient == pkh -> ensure_inputs_ownership(remaining, pkh)
      true -> {:error, "recipient in used output doesn't match transaction public key"}
    end
  end

  defp ensure_public_key_ownership(%Transaction{public_key: pk, signature: sig} = tx) do
    signing_string = Transaction.signing_string(tx)
    case Crypto.verify_signature(pk, signing_string, sig) do
      true -> :ok
      _ -> {:error, "unable to verify signature, public key is not associated to the signing key or the transaction was altered"}
    end
  end
end
