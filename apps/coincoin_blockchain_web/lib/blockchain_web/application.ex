defmodule Coincoin.Blockchain.Web.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      Coincoin.Blockchain.Web.Endpoint
      # Start your own worker by calling: Coincoin.Blockchain.Web.Worker.start_link(arg1, arg2, arg3)
      # worker(Coincoin.Blockchain.Web.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Coincoin.Blockchain.Web.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
