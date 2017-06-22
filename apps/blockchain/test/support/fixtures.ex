defmodule Blockchain.Fixtures do
  @moduledoc "Test helpers"

  alias Blockchain.{Block, P2P.Payload}

  # mock a valid blockchain of n elements + genesis block
  def mock_blockchain(n), do: mock_blockchain([Block.genesis_block()], n)
  def mock_blockchain(acc, n) when n == 0, do: acc
  def mock_blockchain(acc, n) when n > 0 do
    [latest_block | _] = acc
    b = Block.generate_next_block("some block data #{n}", latest_block)
    mock_blockchain([b | acc], n - 1)
  end

  # communication with TCP server
  def open_connection do
    opts = [:binary, packet: 4, active: false]
    :gen_tcp.connect('localhost', 4040, opts)
  end

  def open_connection_and_ping do
    {:ok, socket} = open_connection()
    ping =
      Payload.ping()
      |> Payload.encode!()
    "pong" = send_and_recv(socket, ping)
    {:ok, socket}
  end

  def send_and_recv(socket, payload) do
    :ok = :gen_tcp.send(socket, payload)
    recv(socket)
  end

  def recv(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end
end
