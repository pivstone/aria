defmodule Api.BlobController do
	use Api.Web, :controller

  def download(conn, _params) do
    render conn, "index.json",tag: []
  end

  def upload(conn, _params) do
    render conn, "index.json",tag: []
  end

  def init_upload(conn, _params) do
    render conn, "index.json",tag: []
  end
end