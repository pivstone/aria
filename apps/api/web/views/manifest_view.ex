defmodule Api.ManifestView do
  use Api.Web, :view

  def render("index.json", data: data) do
    data
  end

  def render("index.json", %{data: data}) do
    %{repositories: render(data, Api.ManifestView, "echo.json")}
  end

  def render("echo.json", %{data: data}) do
    %{}
  end
end
