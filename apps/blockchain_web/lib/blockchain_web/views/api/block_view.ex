defmodule Blockchain.Web.API.BlockView do
  use Blockchain.Web, :view

  def render("index.json", %{blocks: blocks}) do
    blocks
  end
end
