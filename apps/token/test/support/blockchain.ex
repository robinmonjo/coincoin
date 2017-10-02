defmodule Token.Test.Blockchain do
  @moduledoc """
  Blockchain used in testing. It provides the APIs required by the token app
  and omits blocks, mining etc ...
  """
  use GenServer

  alias Blockchain.Data

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, []}
  end

  def add(data), do: GenServer.call(__MODULE__, {:add, data})
  def clear, do: GenServer.call(__MODULE__, :clear)
  def blocks, do: GenServer.call(__MODULE__, :blocks)

  def handle_call({:add, data}, _from, chain) do
    case Data.verify(data, chain) do
      :ok -> {:reply, :ok, [%{data: data} | chain]}
      {:error, _} = error -> {:reply, error, chain}
    end
  end
  def handle_call(:clear, _from, _chain), do: {:reply, :ok, []}
  def handle_call(:blocks, _from, chain), do: {:reply, chain, chain}
end