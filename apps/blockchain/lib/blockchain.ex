defmodule Blockchain do
  @moduledoc """
  Documentation for Blockchain.
  """

  alias Blockchain.{Chain, P2P.Client, P2P.Command, P2P.Peers}

  # add a block to the blockchain
  def add(data), do: Command.broadcast_mining_request(data)

  # connect to an existing peer (only localhost for now, just specify a port)
  def connect(uri) do
    Client.connect(uri)
  end

  # list connected peers
  def peers do
    Enum.map(Peers.get_all(), fn p ->
      {:ok, {addr, port}} = :inet.peername(p)

      address =
        addr
        |> :inet_parse.ntoa()
        |> to_string()

      %{address: address, port: port}
    end)
  end

  # returns all blocks
  def blocks do
    Chain.all_blocks()
  end
end
