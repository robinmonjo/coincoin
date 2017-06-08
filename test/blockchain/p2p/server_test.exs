defmodule Blockchain.P2P.ServerTest do
  use ExUnit.Case

  alias Blockchain.P2P.{Server, Clients}

  setup do
    :ok = Clients.remove_all()
    {:ok, socket} = open_connection_and_ping()
    {:ok, socket: socket}
  end

  test "server interaction", %{socket: socket} do
    assert send_and_recv(socket, ~s({"type": "ping"}\n)) == "pong\n"
    assert send_and_recv(socket, ~s({"type": "query_latest"}\n)) == "sending back latest block\n"
    assert send_and_recv(socket, ~s({"type": "query_all"}\n)) == "sending back the entire chain\n"
    assert send_and_recv(socket, ~s({"type": "response_blockchain"}\n)) == "handling incoming blockchain\n"
    assert send_and_recv(socket, ~s({"type": "unknown"}\n)) == "unknown type\n"

    assert send_and_recv(socket, "not valid json\n") == "invalid json\n"
  end

  test "open connection are stored in clients", %{socket: _socket} do
    {:ok, _socket1} = open_connection_and_ping()
    {:ok, _socket2} = open_connection_and_ping()
    n = length(Clients.get_all())
    assert n == 3
  end

  test "broadcast", %{socket: socket} do
    {:ok, socket1} = open_connection_and_ping()
    n = length(Clients.get_all())
    assert n == 2
    payload = "test\n"
    Server.broadcast(payload)
    for s <- [socket, socket1], do: assert recv(s) == payload
  end

  defp open_connection do
    opts = [:binary, packet: :line, active: false]
    :gen_tcp.connect('localhost', 4040, opts)
  end

  defp open_connection_and_ping do
    {:ok, socket} = open_connection()
    assert send_and_recv(socket, ~s({"type": "ping"}\n)) == "pong\n"
    {:ok, socket}
  end

  defp send_and_recv(socket, payload) do
    :ok = :gen_tcp.send(socket, payload)
    recv(socket)
  end

  defp recv(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end
end
