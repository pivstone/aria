defmodule Api.ImageController do
	use Api.Web, :controller

  def catalog(conn, _params) do
    render conn, "catalog.json",image: []
  end

  def tag_list(conn, %{"name" => name}) do
    render conn, "tag_list.json",%{ tag: [],name: name}
  end
end