defmodule Api.ManifestController do
	use Api.Web, :controller

  def show(conn, params) do
    render conn, "index.json",data: params
  end

end