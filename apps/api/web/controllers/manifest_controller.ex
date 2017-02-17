defmodule Api.ManifestController do
	use Api.Web, :controller

  @doc """
  返回指定 Image 的 Manifest
  """
  def show(conn, params) do
    render conn, "index.json",data: params
  end

  @doc """
  保存 Manifest
  """
  def save(conn,params) do
    render conn, "index.json",data: params
  end
end