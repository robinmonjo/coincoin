defmodule Token.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Token.Worker.start_link(a1, a2, a3)
      # worker(Token.Worker, [arg1, arg2, arg3]),
      worker(Token.MyWallet, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Token.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
