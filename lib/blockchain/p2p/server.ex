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
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, packet: 4, active: false, reuseaddr: true])
    Logger.info fn -> "Accepting connections on port #{port}" end
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} =
      Task.Supervisor.start_child(Blockchain.P2P.Server.TaskSupervisor, fn ->
        serve(client)
      end)
    :ok = :gen_tcp.controlling_process(client, pid)
    Peers.add(client)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    msg =
      with {:ok, data} <- :gen_tcp.recv(socket, 0),
           {:ok, command} <- Command.parse(data),
           do: Command.run(command)

    write(socket, msg)
    serve(socket)
  end

  defp write(socket, {:ok, text}) do
    :gen_tcp.send(socket, text)
  end

  defp write(socket, {:error, :unknown_type}) do
    :gen_tcp.send(socket, "unknown type")
  end

  defp write(socket, {:error, :invalid}) do
    :gen_tcp.send(socket, "invalid json")
  end

  # The connection was closed, exit politely.
  defp write(socket, {:error, :closed}), do: socket_died(socket, :shutdown)

  # Unknown error. Write to the client and exit.
  defp write(socket, {:error, error}), do: socket_died(socket, error)

  defp socket_died(socket, exit_status) do
    Peers.remove(socket)
    exit(exit_status)
  end

  def broadcast(data) do
    for p <- Peers.get_all() do
      case write(p, {:ok, data}) do
        {:error, _} ->
          # client is not reachable, forget it
          Peers.remove(p)
        _ ->
          :ok
      end
    end
  end
end
