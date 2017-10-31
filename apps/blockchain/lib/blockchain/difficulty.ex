defmodule Blockchain.Difficulty do
  @moduledoc """
  Module to work with Proof-of-work difficulty. It provides functions to
  help configure difficulty in a coincoin blockchain. See docs/difficulty.md
  """

  alias Blockchain.{Block, ProofOfWork}

  @bit_length 256
  @not_applicable "n/a"

  def benchmark(hashrate \\ nil) do
    block = Block.generate_next_block("data")
    [4, 8, 16, 20, 21]
    |> perform_benchmark(block, [], hashrate)
    |> print_data()
  end

  defp perform_benchmark([], _, acc, _), do: acc
  defp perform_benchmark([zeros | rest], block, acc, hashrate) do
    target = target_with_leading_zeros(zeros)
    data = compute_data(target, block, hashrate)
    perform_benchmark(rest, block, acc ++ [data], hashrate)
  end

  def test_target(target, hashrate \\ nil) do
    block = Block.generate_next_block("data")
    target
    |> base16_to_integer()
    |> compute_data(block, hashrate)
    |> print_data()
  end

  defp compute_data(target, block, hashrate) do
    probab = target / max_target()
    estimated_trials = 1 / probab
    {%Block{nounce: nounce}, time} = benchmarked_proof_of_work(block, target)
    %{
      target: target,
      probab: probab,
      estimated_trials: estimated_trials,
      estimated_time: calculate_estimated_time(estimated_trials, hashrate),
      time: time,
      nounce: nounce,
      hashrate: calculate_hashrate(time, nounce)
    }
  end

  defp calculate_estimated_time(_, nil), do: @not_applicable
  defp calculate_estimated_time(estimated_trials, hashrate), do: estimated_trials / hashrate

  defp calculate_hashrate(time, nounce) when time >= 1, do: nounce/time
  defp calculate_hashrate(_, _), do: @not_applicable

  defp print_data(data) do
    headers = [
      {:target, &("2^#{:math.log2(&1.target)}")},
      :probab,
      :estimated_trials,
      :nounce,
      :estimated_time,
      :time,
      :hashrate
    ]
    Scribe.print(data, width: 150, data: headers)
  end

  # given a hasrate and a desired time what target should I use ?
  def target_for_time(time, hashrate) do
    target = ((1 / time) / hashrate) * max_target()
    target
    |> round()
    |> format_base16()
  end

  # compute PoW on the given block and return {block, seconds_spent}
  defp benchmarked_proof_of_work(block, target) do
    start = System.system_time(:millisecond)
    b = ProofOfWork.compute(block, target)
    finish = System.system_time(:millisecond)
    {b, (finish - start) / 1000}
  end

  # helpers

  defp target_with_leading_zeros(n), do: pow2(@bit_length - n)

  defp max_target, do: pow2(@bit_length)

  defp pow2(n), do: round(:math.pow(2, n))

  def base16_to_integer(hex_str) do
    {n, _} = Integer.parse(hex_str, 16)
    n
  end

  defp format_base16(n) do
    hex_length = div(@bit_length, 4)
    to_string(:io_lib.format("~#{hex_length}.16.0B", [n]))
  end
end
