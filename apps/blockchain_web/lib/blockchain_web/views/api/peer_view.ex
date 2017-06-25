defmodule Blockchain.Web.API.PeerView do
  use Blockchain.Web, :view

  def render("index.json", %{peers: peers}) do
    peers
  end

end
