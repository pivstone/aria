defmodule Api.PageView do
  use Api.Web, :view

  def render("index.json",%{}) do
    %{}
  end
end
