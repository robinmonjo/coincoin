defmodule Blockchain.P2P.Client do
  @moduledoc "Client provides the connect method to connect to another peer"

  alias Blockchain.P2P.Server

  @typep address :: :inet.socket_address() | :inet.hostname()
  @typep port_number :: :inet.port_number()

  @spec connect(integer | String.t() | address, port_number) :: {:ok, port()} | {:error, atom()}

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

    case :gen_tcp.connect(host, port, opts) do
      {:ok, socket} = result ->
        Server.handle_socket(socket)
        result

      _ = error ->
        error
    end
  end
end
