defmodule Blockchain.Chain do
  @moduledoc """
    GenServer that stores the blockchain. Chain is stored in reverse order
    (oldest block last)
  """

  use GenServer

  alias Blockchain.{Block, BlockData}

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, [Block.genesis_block()]}
  end

  def latest_block do
    GenServer.call(__MODULE__, :latest_block)
  end

  def all_blocks do
    GenServer.call(__MODULE__, :all_blocks)
  end

  def add_block(%Block{} = b) do
    GenServer.call(__MODULE__, {:add_block, b})
  end

  def replace_chain(chain) do
    GenServer.call(__MODULE__, {:replace_chain, chain})
  end

  def handle_call(:latest_block, _from, chain) do
    [h | _] = chain
    {:reply, h, chain}
  end

  def handle_call(:all_blocks, _from, chain) do
    {:reply, chain, chain}
  end

  def handle_call({:add_block, %Block{} = b}, _from, chain) do
    [previous_block | _] = chain
    case validate_block(previous_block, b, chain) do
      {:error, reason} ->
        {:reply, {:error, reason}, chain}
      :ok ->
        {:reply, :ok, [b | chain]}
    end
  end

  def handle_call({:replace_chain, new_chain}, _from, chain) do
    case validate_chain(new_chain) do
      :ok -> {:reply, :ok, new_chain}
      {:error, _} = error -> {:reply, error, chain}
    end
  end

  defp validate_block(previous_block, block, chain) do
    cond do
      previous_block.index + 1 != block.index ->
        {:error, "invalid index"}
      previous_block.hash != block.previous_hash ->
        {:error, "invalid previous hash"}
      proof_of_work().verify(block.hash) == false ->
        {:error, "no proof of work"}
      block.hash != Block.compute_hash(block) ->
        {:error, "invalid block hash"}
      true ->
        validate_block_data(block, chain)
    end
  end

  defp validate_block_data(%Block{data: data}, chain), do: BlockData.verify(data, chain)

  def validate_chain(blockchain) when length(blockchain) == 0, do: {:error, "empty chain"}
  def validate_chain([genesis_block | _] = blockchain) when length(blockchain) == 1 do
    if genesis_block == Block.genesis_block() do
      :ok
    else
      {:error, "chain doesn't start with genesis block"}
    end
  end
  def validate_chain([block | [previous_block | rest] = chain]) do
    case validate_block(previous_block, block, chain) do
      {:error, _} = error -> error
      _ -> validate_chain([previous_block | rest])
    end
  end

  defp proof_of_work, do: Application.fetch_env!(:blockchain, :proof_of_work)
end
