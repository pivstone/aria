defmodule Api.CatalogController do
  use Api.Web, :controller
  require Logger



  def get(conn, %{"q" => keyword} = _params) do
    images = Storage.get_repositories(keyword)
    render conn, "catalog.json", %{images: images}
  end


  def get(conn, %{"n" => num} = _params) do
    images = Storage.get_repositories("", num)
    render conn, "catalog.json", %{images: images}
  end

  @doc """
  Search repositories
  """
  def get(conn, %{"q" => keyword, "n" => num} = _params) do
    images = Storage.get_repositories(keyword, num)
    render conn, "catalog.json", %{images: images}
  end

  @doc """
  List reposiotries
  """
  def get(conn, _params) do
    images = Storage.get_repositories("")
    render conn, "catalog.json", %{images: images}
  end

end
