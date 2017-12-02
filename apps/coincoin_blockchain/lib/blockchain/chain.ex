defmodule Coincoin.Blockchain.Chain do
  @moduledoc """
    GenServer that stores the blockchain. Chain is stored in reverse order
    (oldest block last)
  """

  use GenServer

  alias Coincoin.Blockchain.{Block, BlockData}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, [Block.genesis_block()]}
  end

  @spec latest_block() :: Block.t()
  def latest_block do
    GenServer.call(__MODULE__, :latest_block)
  end

  @spec all_blocks() :: [Block.t()]
  def all_blocks do
    GenServer.call(__MODULE__, :all_blocks)
  end

  @spec add_block(Block.t()) :: :ok | {:error, atom()}
  def add_block(%Block{} = b) do
    GenServer.call(__MODULE__, {:add_block, b})
  end

  @spec replace_chain([Block.t()]) :: :ok | {:error, atom()}
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

  @spec validate_block(Block.t(), Block.t(), [Block.t()]) :: :ok | {:error, atom()}
  defp validate_block(previous_block, block, chain) do
    cond do
      previous_block.index + 1 != block.index ->
        {:error, :invalid_block_index}

      previous_block.hash != block.previous_hash ->
        {:error, :invalid_block_previous_hash}

      proof_of_work().verify(block.hash) == false ->
        {:error, :proof_of_work_not_verified}

      block.hash != Block.compute_hash(block) ->
        {:error, :invalid_block_hash}

      true ->
        validate_block_data(block, chain)
    end
  end

  @spec validate_block_data(Block.t(), [Block.t()]) :: :ok | {:error, atom()}
  defp validate_block_data(%Block{data: data}, chain), do: BlockData.verify(data, chain)

  @spec validate_chain([Block.t()]) :: :ok | {:error, atom()}
  def validate_chain([]), do: {:error, :empty_chain}

  def validate_chain([genesis_block | _] = blockchain) when length(blockchain) == 1 do
    if genesis_block == Block.genesis_block() do
      :ok
    else
      {:error, :no_genesis_block}
    end
  end

  def validate_chain([block | [previous_block | rest] = chain]) do
    case validate_block(previous_block, block, chain) do
      {:error, _} = error -> error
      _ -> validate_chain([previous_block | rest])
    end
  end

  @spec proof_of_work() :: module()
  defp proof_of_work, do: Application.fetch_env!(:coincoin_blockchain, :proof_of_work)
end
