defmodule Blockchain.P2P.ServerTest do
  use ExUnit.Case
  import Blockchain.Fixtures

  alias Blockchain.P2P.{Server, Peers}
  alias Blockchain.{Chain, Block}

  setup do
    :ok = Peers.remove_all()
    {:ok, socket} = open_connection_and_ping()
    {:ok, socket: socket}
  end

  test "server interaction, queries", %{socket: socket} do
    assert send_and_recv(socket, json_payload("ping")) == "pong"

    # query latest block
    response = send_and_recv(socket, json_payload("query_latest"))
    blocks = Poison.decode!(response, as: [%Block{}])
    assert blocks == [Chain.latest_block()]

    # query all
    response = send_and_recv(socket, json_payload("query_all"))
    blocks = Poison.decode!(response, as: [%Block{}])
    assert blocks == Chain.all_blocks()

    # unknown, bad json
    assert send_and_recv(socket, json_payload("unknown")) == "unknown type"
    assert send_and_recv(socket, "not valid json") == "invalid json"
  end

  test "server interaction, response", %{socket: socket} do
    remote_chain = mock_blockchain(10)

    [block | _] = remote_chain
    assert send_and_recv(socket, json_payload("response_blockchain", [block])) == "query_all_chain"

    [block | chain] = remote_chain
    assert Chain.replace_chain(chain) == :ok
    assert send_and_recv(socket, json_payload("response_blockchain", [block])) == "append_block"

    assert Chain.replace_chain(remote_chain) == :ok
    [_ | chain] = remote_chain
    assert send_and_recv(socket, json_payload("response_blockchain", chain)) == "nothing"

    assert Chain.replace_chain([Block.genesis_block()])
    assert send_and_recv(socket, json_payload("response_blockchain", remote_chain)) == "replace_chain"
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
    Server.broadcast(payload)
    for s <- [socket, socket1], do: assert recv(s) == payload
  end

  defp json_payload(%{} = payload), do: Poison.encode!(payload)
  defp json_payload(type), do: json_payload(%{ type: type })
  defp json_payload(type, chain), do: json_payload(%{ type: type, chain: chain })
end
