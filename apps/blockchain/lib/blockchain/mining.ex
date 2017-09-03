require Logger

defmodule Blockchain.Mining do
  use GenServer

  alias Blockchain.{Chain, Block, P2P.Command, Data}

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_state) do
    {:ok, {[], {}}}
  end

  def mine(data) do
    GenServer.call(__MODULE__, {:mine, data})
  end

  def block_mined(%Block{} = b) do
    GenServer.call(__MODULE__, {:block_mined, b})
  end

  def handle_call({:mine, data}, _from, {pool, _} = state) do
    if data_in_pool?(pool, data) do
      {:reply, :already_in_pool, state}
    else
      {:reply, :ok, add_to_pool(state, data)}
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

  defp add_to_pool({pool, {}}, data), do: {pool ++ [data], start_mining(data)}
  defp add_to_pool({pool, mining}, data) do
    {pool ++ [data], mining}
  end

  defp data_in_pool?(pool, data) do
    Enum.find(pool, &(Data.hash(&1) == Data.hash(data))) != nil
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
    mined_block = Block.perform_proof_of_work(b)
    case Chain.add_block(mined_block) do
      :ok ->
        Command.broadcast_new_block(mined_block)
        Logger.info fn -> "I mined your sheet" end
      {:error, _reason} -> nil
    end
  end
end
