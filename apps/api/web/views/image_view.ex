defmodule Api.ImageView do
  use Api.Web, :view

  def render("index.json", %{}) do
    %{}
  end

  def render("image.json", %{image: image}) do
    image
  end

  def render("tag.json", %{image: name}) do
    name
  end
end
