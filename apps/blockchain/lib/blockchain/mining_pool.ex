require Logger

defmodule Blockchain.MiningPool do
  @moduledoc "GenServer responsible for block mining"
  use GenServer

  alias Blockchain.{Chain, Block, P2P.Command, Data}

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_state) do
    {:ok, {[], {}}}
  end

  def add(data) do
    GenServer.call(__MODULE__, {:mine, data})
  end

  def block_mined(%Block{} = b) do
    GenServer.call(__MODULE__, {:block_mined, b})
  end

  def handle_call({:mine, data}, _from, {pool, _} = state) do
    case verify_data(data, pool) do
      :ok ->
        {:reply, :ok, add_to_pool(state, data)}
      {:error, _reason} = error ->
        {:reply, error, state}
    end
  end

  def handle_call({:block_mined, %Block{index: i} = b}, _from, {pool, {_, pid, %Block{index: j}} = mining}) when i == j do
    Process.exit(pid, :kill)
    pool = remove_from_pool(b, pool)
    {:reply, :ok, {pool, mining}}
  end
  def handle_call({:block_mined, b}, _from, {pool, mining}) do
    pool = remove_from_pool(b, pool)
    {:reply, :ok, {pool, mining}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {pool, {mref, _, block}}) when ref == mref do
    pool = remove_from_pool(block, pool)
    {:noreply, mine_next_block(pool)}
  end

  defp verify_data(data, pool) do
    if Enum.find(pool, &(Data.hash(&1) == Data.hash(data))) != nil do
      {:error, :already_in_pool}
    else
      Data.verify(data, Chain.all_blocks())
    end
  end

  defp add_to_pool({pool, {}}, data), do: {pool ++ [data], start_mining(data)}
  defp add_to_pool({pool, mining}, data) do
    {pool ++ [data], mining}
  end

  defp remove_from_pool(%Block{data: data}, pool) do
    Enum.reject(pool, &(Data.hash(&1) == Data.hash(data)))
  end

  defp mine_next_block([]), do: {[], {}}
  defp mine_next_block([data | _] = pool), do: {pool, start_mining(data)}

  defp start_mining(data) do
    b = Block.generate_next_block(data)
    {pid, ref} = spawn_monitor(fn() -> mine_block(b) end)
    {ref, pid, b}
  end

  defp mine_block(%Block{} = b) do
    mined_block = proof_of_work().compute(b)
    case Chain.add_block(mined_block) do
      :ok ->
        Logger.info fn -> "I mined block number #{mined_block.index}" end
        Command.broadcast_new_block(mined_block)
        :ok
      {:error, _reason} = error -> error
    end
  end

  defp proof_of_work, do: Application.fetch_env!(:blockchain, :proof_of_work)
end
