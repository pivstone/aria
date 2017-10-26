defmodule Dashboard.RepoController do
  use Dashboard.Web, :controller
  alias Dashboard.Repo
  @doc """
  获取 repo list 信息
  """
  def list(conn, param) do
    body =
      param
        |> Map.get("mask", :"_")
        |> Repo.list
        |> Poison.encode!
    conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(:ok, body)
  end

  @doc """
  retrieve image info via name
  """
  def retrieve(conn, %{"name" => name} = _param) do
    repo = Repo.retrieve(name)
    if repo == nil do
      conn
       |> send_resp(:not_found, "")
       |> halt
    else
      body = Poison.encode!(repo)
      conn
        |> put_resp_header("content-type", "application/json")
        |> send_resp(:ok, body)
    end
  end

  @doc """
  fetch image manifest config via name & reference
  """
  def manifest(conn, %{"name" => name, "reference" => reference} = _param) do
    body =
      name
      |> Manifest.config(reference)
      |> Poison.encode!
    conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(:ok, body)
  end

  def manifest(conn, %{"name" => _name} = _param) do
    body =
      [%{"reference" => "missing"}]
      |>  Poison.encode!
    conn
     |> put_resp_header("content-type", "application/json")
     |> send_resp(:bad_request, body)
     |> halt
  end

  def manifest(conn, %{"reference" => _reference} = _param) do
    body =
      [%{"name" => "name"}]
      |>  Poison.encode!
    conn
     |> put_resp_header("content-type", "application/json")
     |> send_resp(:bad_request, body)
     |> halt
  end

  def manifest(conn, _param) do
    body =
      [%{"reference" => "missing"}, %{"name" => "missing"}]
      |>  Poison.encode!
    conn
     |> put_resp_header("content-type", "application/json")
     |> send_resp(:bad_request, body)
     |> halt
  end
end
