defmodule Api.TagController do
  use Api.Web, :controller
  require Logger

  @doc """
  fetch repo tag list
  """
  def get(conn, %{"name" => name}) do
    tags = Storage.get_tags(name)
    render conn, "tag_list.json", %{tag: tags, name: name}
  end
end
