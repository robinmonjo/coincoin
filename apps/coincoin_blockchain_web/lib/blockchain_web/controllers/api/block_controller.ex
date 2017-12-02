defmodule Coincoin.Blockchain.Web.API.BlockController do
  use Coincoin.Blockchain.Web, :controller

  alias Coincoin.Blockchain

  def index(conn, _params) do
    render(conn, "index.json", blocks: Blockchain.blocks())
  end

  def create(conn, %{"data" => data}) do
    Blockchain.add(data)
    render(conn, "index.json", blocks: Blockchain.blocks())
  end
end
