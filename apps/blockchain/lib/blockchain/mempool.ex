require Logger

defmodule Blockchain.Mempool do
  @moduledoc "GenServer responsible for block mining"
  use GenServer

  alias Blockchain.{Chain, Block, P2P.Command, BlockData}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @opaque pool :: [any()]
  @opaque mining :: {} | {reference(), pid(), Block.t()}
  @type state :: {pool, mining}

  def init(_state) do
    {:ok, {[], {}}}
  end

  @spec add(BlockData.t()) :: :ok | {:error, atom()} | {:error, String.t()}
  def add(data) do
    GenServer.call(__MODULE__, {:mine, data})
  end

  @spec block_mined(Block.t()) :: :ok
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

  def handle_call(
        {:block_mined, %Block{index: i} = b},
        _from,
        {pool, {_, pid, %Block{index: j}} = mining}
      )
      when i == j do
    Process.exit(pid, :kill)
    pool = remove_from_pool(b, pool)
    {:reply, :ok, {pool, mining}}
  end

  def handle_call({:block_mined, b}, _from, {pool, mining}) do
    pool = remove_from_pool(b, pool)
    {:reply, :ok, {pool, mining}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {pool, {mref, _, block}})
      when ref == mref do
    pool = remove_from_pool(block, pool)
    {:noreply, mine_next_block(pool)}
  end

  @spec verify_data(any(), pool) :: :ok | {:error, atom()} | {:error, String.t()}
  defp verify_data(data, pool) do
    if Enum.find(pool, &(BlockData.hash(&1) == BlockData.hash(data))) != nil do
      {:error, :already_in_pool}
    else
      BlockData.verify(data, Chain.all_blocks())
    end
  end

  @spec add_to_pool(state, any()) :: state
  defp add_to_pool({pool, {}}, data), do: {pool ++ [data], start_mining(data)}

  defp add_to_pool({pool, mining}, data) do
    {pool ++ [data], mining}
  end

  @spec remove_from_pool(Block.t(), pool) :: list
  defp remove_from_pool(%Block{data: data}, pool) do
    Enum.reject(pool, &(BlockData.hash(&1) == BlockData.hash(data)))
  end

  @spec mine_next_block(pool) :: state
  defp mine_next_block([]), do: {[], {}}
  defp mine_next_block([data | _] = pool), do: {pool, start_mining(data)}

  @spec start_mining(any()) :: mining
  defp start_mining(data) do
    b = Block.generate_next_block(data)
    {pid, ref} = spawn_monitor(fn -> mine_block(b) end)
    {ref, pid, b}
  end

  @spec mine_block(Block.t()) :: :ok | {:error, String.t()}
  defp mine_block(%Block{} = b) do
    mined_block = proof_of_work().compute(b)

    case Chain.add_block(mined_block) do
      :ok ->
        Logger.info(fn -> "I mined block number #{mined_block.index}" end)
        Command.broadcast_new_block(mined_block)
        :ok

      {:error, _reason} = error ->
        error
    end
  end

  @spec proof_of_work() :: module()
  defp proof_of_work, do: Application.fetch_env!(:blockchain, :proof_of_work)
end
