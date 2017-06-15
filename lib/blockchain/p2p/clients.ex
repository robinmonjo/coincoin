defmodule Blockchain.P2P.Clients do
  @moduledoc "Agent that stores a list of connected peers"

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add(client) do
    Agent.update(__MODULE__, fn(clients) ->
      [client | clients]
    end)
  end

  def remove(client) do
    Agent.update(__MODULE__, fn(clients) ->
      Enum.filter(clients, fn(c) ->
        c != client
      end)
    end)
  end

  def get_all do
    Agent.get(__MODULE__, fn(clients) ->
      clients
    end)
  end

  def remove_all do
    Agent.update(__MODULE__, fn(_clients) ->
      []
    end)
  end
end
