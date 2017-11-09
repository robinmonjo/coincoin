require Logger

defmodule Blockchain.P2P.Server do
  @moduledoc "TCP server to handle communications between peers"

  alias Blockchain.P2P.{Peers, Command}

  @spec accept(integer) :: no_return()
  def accept(port) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener
    #                        crashes
    #
    opts = [:binary, packet: 4, active: false, reuseaddr: true]
    {:ok, listen_socket} = :gen_tcp.listen(port, opts)

    Logger.info(fn -> "accepting connections on port #{port}" end)
    loop_acceptor(listen_socket)
  end

  @spec loop_acceptor(port()) :: no_return()
  defp loop_acceptor(listen_socket) do
    {:ok, socket} = :gen_tcp.accept(listen_socket)

    case handle_socket(socket) do
      :ok ->
        loop_acceptor(listen_socket)

      {:error, reason} ->
        Logger.info(fn -> "unable to accept connection: #{reason}" end)
    end
  end

  @spec handle_socket(port()) :: :ok | {:error, atom()}
  def handle_socket(socket) do
    Peers.add(socket)

    {:ok, pid} =
      Task.Supervisor.start_child(Blockchain.P2P.Server.TasksSupervisor, fn ->
        serve(socket)
      end)

    :gen_tcp.controlling_process(socket, pid)
  end

  @spec serve(port()) :: no_return()
  defp serve(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        handle_incoming_data(socket, data)
        serve(socket)

      {:error, _} ->
        Logger.info(fn -> "socket died" end)
        Peers.remove(socket)
        exit(:shutdown)
    end
  end

  @spec broadcast(String.t(), [port()]) :: :ok
  def broadcast(_data, peers \\ Peers.get_all())
  def broadcast(_data, []), do: :ok

  def broadcast(data, [p | peers]) do
    case send_data(data, p) do
      {:error, _} ->
        # client is not reachable, forget it
        Logger.info(fn -> "socket not reachable, forgeting it" end)
        Peers.remove(p)

      _ ->
        broadcast(data, peers)
    end
  end

  @spec handle_incoming_data(port(), String.t()) :: :ok | {:error, atom()} | no_return()
  defp handle_incoming_data(socket, data) do
    case Command.handle(data) do
      {:ok, response} ->
        send_data(response, socket)

      :ok ->
        :ok

      {:error, :unknown_type} ->
        send_data("unknown type", socket)

      {:error, :invalid} ->
        send_data("invalid json", socket)

      {:error, reason} ->
        Logger.info(fn -> reason end)
    end
  end

  @spec send_data(iodata(), port()) :: :ok | {:error, atom()}
  def send_data(data, socket) do
    :gen_tcp.send(socket, data)
  end
end
