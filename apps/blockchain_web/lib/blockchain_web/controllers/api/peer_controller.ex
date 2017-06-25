defmodule Blockchain.Web.API.PeerController do
  use Blockchain.Web, :controller

  def index(conn, _params) do
    render conn, "index.json", peers: Blockchain.peers()
  end

  def create(conn, %{"port" => port}) do
    :ok = Blockchain.connect(port)
    render conn, "index.json", peers: Blockchain.peers()
  end
end
