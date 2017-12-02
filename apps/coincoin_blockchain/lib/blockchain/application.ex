defmodule Coincoin.Blockchain.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Application.fetch_env!(:coincoin_blockchain, :port)

    # Define workers and child supervisors to be supervised
    children = [
      {Coincoin.Blockchain.Chain, []},
      {Coincoin.Blockchain.Mempool, []},

      # P2P processes
      {Coincoin.Blockchain.P2P.Peers, []},
      {Task.Supervisor, name: Coincoin.Blockchain.P2P.Server.TasksSupervisor},
      {Task, fn -> Coincoin.Blockchain.P2P.Server.accept(port) end}
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Coincoin.Blockchain.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
