defmodule Coincoin.Blockchain.Web.API.PeerView do
  use Coincoin.Blockchain.Web, :view

  def render("index.json", %{peers: peers}) do
    peers
  end
end
