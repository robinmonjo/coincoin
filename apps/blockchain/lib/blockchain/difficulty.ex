defmodule Blockchain.Difficulty do
  alias Blockchain.{Block, ProofOfWork}

  @bit_length 256

  def benchmark(hashrate \\ nil) do
    block = Block.generate_next_block("data")
    print_header()
    benchmark([2, 4, 8, 16, 20, 25], block, hashrate)
  end
  def benchmark([], _, _), do: :ok
  def benchmark([leading_zeros | rem], block, hashrate) do
    target = target_with_leading_zeros(leading_zeros)
    data = compute_data(target, block, hashrate)
    print_data(data)
    benchmark(rem, block, hashrate)
  end

  def test_target(target) do
    block = Block.generate_next_block("data")
    {n, _} = Integer.parse(target, 16)
    data = compute_data(n, block, nil)
    print_data(data)
  end

  defp compute_data(target, block, hashrate) do
    probability = target / max_target()
    guesses = 1 / probability
    {%Block{nounce: nounce}, time} = benchmarked_proof_of_work(block, target)
    %{
      difficulty: target,
      probability: probability,
      guesses: guesses,
      estimated_time: if(hashrate, do: guesses / hashrate, else: "N/A"),
      time: time,
      nounce: nounce,
      hashrate: if(time >= 1, do: nounce / time, else: "N/A")
    }
  end

  defp print_header do
    header = ~w(difficulty probability guesses nounce estimated_time time hashrate)
    IO.puts Enum.join(header, "\t")
  end
  defp print_data(data) do
    line = [data.difficulty, data.probability, data.guesses, data.nounce, data.estimated_time, data.time, data.hashrate]
    IO.puts Enum.join(line, "\t")
  end

  # given a hasrate and a desired time what target should I use ?
  def target_for_time(time, hashrate) do
    # time = guesses / hashrate
    # time = (1 / probability) / hashrate
    # time = (1 / (target / max_target)) / hashrate
    # time * hashrate = 1 / (target / max_target)
    # time * hashrate * (target / max_target) = 1
    # (target / max_target) = (1 / time) / hashrate
    # target = ((1 / time) / hashrate) * max_target
    target = ((1 / time) / hashrate) * max_target() |> round()
    format_base16(target)
  end

  defp target_with_leading_zeros(d), do: pow2(@bit_length - d)
  defp max_target, do: pow2(@bit_length)
  defp pow2(n), do: :math.pow(2, n) |> round()
  defp format_base16(n) do
    hex_length = @bit_length / 4 |> round()
    :io.format("~#{hex_length}.16.0B~n", [n])
  end

  # compute PoW on the given block and return {block, second_spent}
  defp benchmarked_proof_of_work(block, target) do
    start = System.system_time(:millisecond)
    b = ProofOfWork.compute2(block, target)
    finish = System.system_time(:millisecond)
    {b, (finish - start) / 1000}
  end
end