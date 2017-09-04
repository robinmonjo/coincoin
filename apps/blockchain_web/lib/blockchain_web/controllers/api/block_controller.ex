defmodule Blockchain.Web.API.BlockController do
  use Blockchain.Web, :controller

  def index(conn, _params) do
    render conn, "index.json", blocks: Blockchain.blocks()
  end

  def create(conn, %{"data" => data}) do
    Blockchain.add(data)
    render conn, "index.json", blocks: Blockchain.blocks()
  end
end
