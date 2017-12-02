defmodule Coincoin.Token.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Coincoin.Token.MyWallet
    ]

    opts = [strategy: :one_for_one, name: Coincoin.Token.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
