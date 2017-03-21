defmodule Api.ImageView do
  use Api.Web, :view

  def render("index.json",%{}) do
    %{}
  end

  def render("catalog.json", %{images: images}) do
    %{repositories: render_many(images, Api.ImageView, "image.json")}
  end

  def render("tag_list.json", %{ tag: tag,name: name}) do
    %{name: name,
      tags: render_many(tag, Api.ImageView, "tag.json")}
  end

  def render("image.json", %{image: image}) do
    %{name: image.name}
  end

  def render("tag.json", %{image: name}) do
    name
  end
end
