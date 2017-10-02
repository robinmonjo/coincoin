require Logger

defmodule Blockchain.P2P.Server do
  @moduledoc "TCP server to handle communications between peers"

  alias Blockchain.P2P.{Peers, Command}

  # Servers
  def accept(port) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener
    #                        crashes
    #
    {:ok, listen_socket} = :gen_tcp.listen(port,
                      [:binary, packet: 4, active: false, reuseaddr: true])
    Logger.info fn -> "accepting connections on port #{port}" end
    loop_acceptor(listen_socket)
  end

  defp loop_acceptor(listen_socket) do
    {:ok, socket} = :gen_tcp.accept(listen_socket)
    handle_socket(socket)
    loop_acceptor(listen_socket)
  end

  def handle_socket(socket) do
    Peers.add(socket)
    {:ok, pid} =
      Task.Supervisor.start_child(Blockchain.P2P.Server.TasksSupervisor, fn ->
        serve(socket)
      end)
    :ok = :gen_tcp.controlling_process(socket, pid)
  end

  defp serve(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        handle_incoming_data(socket, data)
        serve(socket)
      {:error, _} ->
        Logger.info fn -> "socket died" end
        Peers.remove(socket)
        exit(:shutdown)
    end
  end

  def broadcast(data) do
    for p <- Peers.get_all() do
      case :gen_tcp.send(p, data) do
        {:error, _} ->
          # client is not reachable, forget it
          Logger.info fn -> "socket not reachable, forgeting it" end
          Peers.remove(p)
        _ ->
          :ok
      end
    end
  end

  defp handle_incoming_data(socket, data) do
    case Command.handle(data) do
      {:ok, response} ->
        :gen_tcp.send(socket, response)
      :ok ->
        :ok
      {:error, :unknown_type} ->
        :gen_tcp.send(socket, "unknown type")
      {:error, :invalid} ->
        :gen_tcp.send(socket, "invalid json")
    end
  end
end
