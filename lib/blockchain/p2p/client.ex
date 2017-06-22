defmodule Blockchain.P2P.Client do
  @moduledoc "Client provides the connect method to connect to another peer"

  alias Blockchain.P2P.{Server, Payload}

  def connect(port) do
    opts = [:binary, packet: 4, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', port, opts)
    Server.handle_socket(socket)

    query =
      Payload.query_all()
      |> Payload.encode!()
    :ok = :gen_tcp.send(socket, query)
  end
end
