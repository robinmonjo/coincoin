defmodule Blockchain.Web.PageController do
  use Blockchain.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
