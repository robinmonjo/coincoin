defmodule Coincoin.Blockchain.Web.API.PeerController do
  use Coincoin.Blockchain.Web, :controller

  alias Coincoin.Blockchain

  def index(conn, _params) do
    render(conn, "index.json", peers: Blockchain.peers())
  end

  def create(conn, %{"uri" => uri}) do
    :ok = Blockchain.connect(uri)
    render(conn, "index.json", peers: Blockchain.peers())
  end
end
