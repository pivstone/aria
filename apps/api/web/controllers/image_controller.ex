defmodule Api.ImageController do
	use Api.Web, :controller



  def catalog(conn, %{"q" => keyword } = _params) do
    images = Storage.driver().get_repositories(keyword)
    render conn, "catalog.json",%{ images: images}
  end

  def catalog(conn, %{"q" => keyword,"n" => num} = _params) do
    images = Storage.driver().get_repositories(keyword,num)
    render conn, "catalog.json",%{ images: images}
  end

  def catalog(conn, _params) do
    images = Storage.driver().get_repositories("")
    render conn, "catalog.json",%{ images: images}
  end

  def get(conn, %{"name" => name}) do
    tags = Storage.driver().get_tags(name)
    render conn, "tag_list.json",%{ tag: tags,name: name}
  end
end