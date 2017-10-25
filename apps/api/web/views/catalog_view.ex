defmodule Api.CatalogView do
  use Api.Web, :view

  def render("catalog.json", %{images: images}) do
    %{repositories: render_many(images, Api.ImageView, "image.json")}
  end
end
