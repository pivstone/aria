defmodule Api.BlobController do
	use Api.Web, :controller

  def get(conn, _params) do
    render conn, "index.json",tag: []
  end

  def put(conn, _params) do
    render conn, "index.json",tag: []
  end

  def head(conn, _params) do
    render conn, "index.json",tag: []
  end

  def patch(conn, _params) do
    render conn, "index.json",tag: []
  end

  def post(conn, _params) do
    render conn, "index.json",tag: []
  end

  def init_upload(conn, _params) do
    render conn, "index.json",tag: []
  end

  def delete(conn,_params) do
    render conn, "index.json",tag: []
  end
end