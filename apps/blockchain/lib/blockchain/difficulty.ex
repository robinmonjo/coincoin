defmodule Blockchain.Difficulty do
  @moduledoc """
  Module to work with Proof-of-work difficulty. It provides functions to
  help configure difficulty in a coincoin blockchain. See docs/difficulty.md
  """

  alias Blockchain.{Block, ProofOfWork}

  @bit_length 256

  @typep optional_float :: nil | float

  @type t :: %{
          target: integer,
          probab: float,
          estimated_trials: float,
          estimated_time: optional_float,
          time: float,
          nonce: non_neg_integer,
          hashrate: optional_float
        }

  @spec benchmark(optional_float) :: :ok
  def benchmark(hashrate \\ nil) do
    block = Block.generate_next_block("data")

    [4, 8, 16, 20, 21]
    |> perform_benchmark(block, [], hashrate)
    |> print_data()
  end

  @spec perform_benchmark([integer], Block.t(), [t], optional_float) :: [t]
  defp perform_benchmark([], _, acc, _), do: acc

  defp perform_benchmark([zeros | rest], block, acc, hashrate) do
    target = target_with_leading_zeros(zeros)
    data = compute_data(target, block, hashrate)
    perform_benchmark(rest, block, acc ++ [data], hashrate)
  end

  @spec test_target(String.t(), optional_float) :: :ok
  def test_target(target, hashrate \\ nil) do
    block = Block.generate_next_block("data")

    target
    |> base16_to_integer()
    |> compute_data(block, hashrate)
    |> print_data()
  end

  @spec compute_data(integer, Block.t(), optional_float) :: t
  defp compute_data(target, block, hashrate) do
    probab = target / max_target()
    estimated_trials = 1 / probab
    {%Block{nonce: nonce}, time} = benchmarked_proof_of_work(block, target)

    %{
      target: target,
      probab: probab,
      estimated_trials: estimated_trials,
      estimated_time: calculate_estimated_time(estimated_trials, hashrate),
      time: time,
      nonce: nonce,
      hashrate: calculate_hashrate(time, nonce)
    }
  end

  @spec calculate_estimated_time(float, optional_float) :: nil | float
  defp calculate_estimated_time(_, nil), do: nil
  defp calculate_estimated_time(estimated_trials, hashrate), do: estimated_trials / hashrate

  @spec calculate_estimated_time(float, integer) :: nil | float
  defp calculate_hashrate(time, nonce) when time >= 1, do: nonce / time
  defp calculate_hashrate(_, _), do: nil

  @spec print_data(t | [t]) :: :ok
  defp print_data(data) do
    headers = [
      {:target, &"2^#{:math.log2(&1.target)}"},
      :probab,
      :estimated_trials,
      :nonce,
      :estimated_time,
      :time,
      :hashrate
    ]

    Scribe.print(data, width: 150, data: headers)
  end

  # given a hasrate and a desired time what target should I use ?

  @spec target_for_time(number, number) :: String.t()
  def target_for_time(time, hashrate) do
    target = 1 / time / hashrate * max_target()

    target
    |> round()
    |> format_base16()
  end

  # compute PoW on the given block and return {block, seconds_spent}

  @spec benchmarked_proof_of_work(Block.t(), integer) :: {Block.t(), float}
  defp benchmarked_proof_of_work(block, target) do
    start = System.system_time(:millisecond)
    b = ProofOfWork.compute(block, target)
    finish = System.system_time(:millisecond)
    {b, (finish - start) / 1000}
  end

  # helpers
  @spec target_with_leading_zeros(integer) :: number()
  defp target_with_leading_zeros(n), do: pow2(@bit_length - n)

  @spec max_target() :: number()
  defp max_target, do: pow2(@bit_length)

  @spec pow2(number) :: integer
  defp pow2(n), do: round(:math.pow(2, n))

  @spec base16_to_integer(String.t()) :: integer
  def base16_to_integer(hex_str) do
    {n, _} = Integer.parse(hex_str, 16)
    n
  end

  @spec format_base16(integer) :: String.t()
  defp format_base16(n) do
    hex_length = div(@bit_length, 4)
    to_string(:io_lib.format("~#{hex_length}.16.0B", [n]))
  end
end
