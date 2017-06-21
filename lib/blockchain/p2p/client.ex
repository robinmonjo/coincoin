defmodule Blockchain.P2P.Client do
  alias Blockchain.P2P.Server

  def connect(port) do
    opts = [:binary, packet: 4, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', port, opts)
    Server.handle_socket(socket)
    # TODO query all chain when joining
  end

end
