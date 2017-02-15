defmodule Api.PageController do
  use Api.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end


  def upload(conn, _params) do
    IO.puts inspect conn
    render conn, "index.html"
  end
end
