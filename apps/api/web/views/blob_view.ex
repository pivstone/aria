defmodule Api.BlobView do
  use Api.Web, :view

  def render("index.json", %{}) do
    %{}
  end

  def render("tag.json", %{tag: tag}) do
    %{name: tag.name}
  end
end
