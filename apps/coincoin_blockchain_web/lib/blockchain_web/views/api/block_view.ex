defmodule Coincoin.Blockchain.Web.API.BlockView do
  use Coincoin.Blockchain.Web, :view

  def render("index.json", %{blocks: blocks}) do
    blocks
  end
end
