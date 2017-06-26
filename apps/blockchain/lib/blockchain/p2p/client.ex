defmodule Blockchain.P2P.Client do
  @moduledoc "Client provides the connect method to connect to another peer"

  alias Blockchain.P2P.{Server, Payload}

  def connect(port) when is_integer(port) do
    connect('localhost', port)
  end

  def connect(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: host, scheme: "tcp", port: port} ->
        connect(to_charlist(host), port)
      _ ->
        [host, port] = String.split(url, ":")
        connect(to_charlist(host), String.to_integer(port))
    end
  end

  def connect(host, port) do
    opts = [:binary, packet: 4, active: false]
    {:ok, socket} = :gen_tcp.connect(host, port, opts)
    Server.handle_socket(socket)

    query =
      Payload.query_all()
      |> Payload.encode!()
    :ok = :gen_tcp.send(socket, query)
  end
end
