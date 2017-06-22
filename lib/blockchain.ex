defmodule Blockchain do
  @moduledoc """
  Documentation for Blockchain.
  """

  alias Blockchain.{Block, Chain, P2P.Client, P2P.Command, P2P.Peers}

  # add a block to the blockchain
  def create_block(data)  do
    block = Block.generate_next_block(data)
    :ok = Chain.add_block(block)
    Command.broadcast_new_block(block)
  end

  # connect to an existing peer (only localhost for now, just specify a port)
  def connect_to_peer(port) do
    Client.connect(port)
  end

  # list connected peers
  def list_peers do
    Enum.map Peers.get_all(), &(:inet.peernames(&1))
  end
end
