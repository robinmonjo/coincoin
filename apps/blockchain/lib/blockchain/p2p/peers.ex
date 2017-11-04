defmodule Blockchain.P2P.Peers do
  @moduledoc "Agent that stores a list of connected peers"

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add(peer) do
    Agent.update(__MODULE__, fn peers ->
      [peer | peers]
    end)
  end

  def remove(peer) do
    Agent.update(__MODULE__, fn peers ->
      Enum.filter(peers, fn p ->
        p != peer
      end)
    end)
  end

  def get_all do
    Agent.get(__MODULE__, fn peers ->
      peers
    end)
  end

  def remove_all do
    Agent.update(__MODULE__, fn _peers ->
      []
    end)
  end
end
