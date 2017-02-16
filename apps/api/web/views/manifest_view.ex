defmodule Api.ManifestView do
  use Api.Web, :view


  def render("index.json", %{data: data}) do
    data
  end

end
