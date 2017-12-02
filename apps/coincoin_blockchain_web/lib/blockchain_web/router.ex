defmodule Coincoin.Blockchain.Web.Router do
  use Coincoin.Blockchain.Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", Coincoin.Blockchain.Web do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  scope "/api", Coincoin.Blockchain.Web.API do
    pipe_through(:api)

    resources("/blocks", BlockController, only: [:index, :create])
    resources("/peers", PeerController, only: [:index, :create])
  end
end
