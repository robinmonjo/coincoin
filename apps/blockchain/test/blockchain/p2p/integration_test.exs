defmodule Blockchain.P2P.IntegrationTest do
  use ExUnit.Case
  import Blockchain.Fixtures

  alias Blockchain.{Chain, P2P.Server, P2P.Peers, P2P.Payload}

  setup do
    :ok = Peers.remove_all()
    {:ok, socket} = open_connection_and_ping()
    {:ok, socket: socket}
  end

  test "ping command", %{socket: socket} do
    payload =
      Payload.ping()
      |> Payload.encode!()

    assert send_and_recv(socket, payload) == "pong"
  end

  test "query latest command", %{socket: socket} do
    payload =
      Payload.query_latest()
      |> Payload.encode!()

    response = send_and_recv(socket, payload)
    {:ok, payload} = Payload.decode(response)
    assert payload == %Payload{type: "response_blockchain", blocks: [Chain.latest_block()]}
  end

  test "query all command", %{socket: socket} do
    payload =
      Payload.query_all()
      |> Payload.encode!()

    response = send_and_recv(socket, payload)
    {:ok, payload} = Payload.decode(response)
    assert payload == %Payload{type: "response_blockchain", blocks: Chain.all_blocks()}
  end

  test "bad commands", %{socket: socket} do
    assert send_and_recv(socket, Poison.encode!(%{type: "unknown"})) == "unknown type"
    assert send_and_recv(socket, "not valid json") == "invalid json"
  end

  test "server interaction, response", %{socket: socket} do
    remote_chain = mock_blockchain(10)

    [block | _] = remote_chain

    payload =
      [block]
      |> Payload.response_blockchain()
      |> Payload.encode!()

    {:ok, response} = Payload.decode(send_and_recv(socket, payload))
    assert response == Payload.query_all()
  end

  test "open connection are stored in clients", %{socket: _socket} do
    {:ok, _socket1} = open_connection_and_ping()
    {:ok, _socket2} = open_connection_and_ping()
    n = length(Peers.get_all())
    assert n == 3
  end

  test "broadcast", %{socket: socket} do
    {:ok, socket1} = open_connection_and_ping()
    n = length(Peers.get_all())
    assert n == 2
    payload = "test"
    assert Server.broadcast(payload) == [:ok, :ok]
    for s <- [socket, socket1], do: assert(recv(s) == payload)
  end
end
