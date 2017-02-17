defmodule Api.ManifestController do
	use Api.Web, :controller

  @doc """
  返回指定 Image 的 Manifest
  """
  def get(conn, params) do
    render conn, "index.json",data: params
  end

  @doc """
  保存 Manifest
  """
  def put(conn,params) do
    render conn, "index.json",data: params
  end

  @doc """
  删除 Manifest
  """
  def delete(conn,params) do
    render conn, "index.json",data: params
  end

  @doc """
  检车 Manifest 是否存在
  """
  def head(conn,params) do
    render conn, "index.json",data: params
  end
end