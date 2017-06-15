defmodule Blockchain.Chain do
  @moduledoc """
    GenServer that stores the blockchain. Chain is stored in reverse order
    (oldest block last)
  """

  use GenServer

  alias Blockchain.Block

  def start_link do
    GenServer.start_link(__MODULE__, [Block.genesis_block()], name: __MODULE__)
  end

  def init(initial_chain) do
    {:ok, initial_chain}
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
    case validate_new_block(previous_block, b) do
      {:error, reason} ->
        {:reply, {:error, reason}, chain}
      :ok ->
        {:reply, :ok, [b | chain]}
    end
  end

  def handle_call({:replace_chain, new_chain}, _from, chain) do
    case validate_chain(new_chain) do
      true -> {:reply, :ok, new_chain}
      _ -> {:reply, :error, chain}
    end
  end

  defp validate_new_block(previous_block, block) do
    cond do
      previous_block.index + 1 != block.index ->
        {:error, "invalid index"}
      previous_block.hash != block.previous_hash ->
        {:error, "invalid previous hash"}
      block.hash != Block.compute_hash(block) ->
        {:error, "invalid block hash"}
      true ->
        :ok
    end
  end

  def validate_chain(blockchain) when length(blockchain) == 0, do: false # should at least have a genesis bloc

  def validate_chain(blockchain) when length(blockchain) == 1 do
    [genesis_block | _] = blockchain
    genesis_block == Block.genesis_block()
  end

  def validate_chain(blockchain) do
    [block | [previous_block | rest]] = blockchain
    case validate_new_block(previous_block, block) do
      {:error, _} -> false
      _ -> validate_chain([previous_block | rest])
    end
  end

end
