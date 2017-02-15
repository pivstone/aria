defmodule Api.ImageView do
  use Api.Web, :view

  def render("catalog.json", %{image: image}) do
    %{repositories: render_many(image, Api.ImageView, "image.json")}
  end

  def render("tag_list.json", %{ tag: tag,name: name}) do
    %{name: name,
      tags: render_many(tag, Api.ImageView, "tag.json")}
  end

  def render("image.json", %{image: image}) do
    %{name: image.name}
  end

  def render("tag.json", %{tag: tag}) do
    %{name: tag.name}
  end
end
