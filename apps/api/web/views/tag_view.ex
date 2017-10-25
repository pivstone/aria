defmodule Api.TagView do
  use Api.Web, :view


  def render("tag_list.json", %{tag: tag, name: name}) do
    %{name: name,
      tags: render_many(tag, Api.ImageView, "tag.json")}
  end

end
