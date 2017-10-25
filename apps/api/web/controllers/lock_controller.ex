defmodule Api.LockController do
  use Api.Web, :controller
  require Logger



  @doc """
  Lock repo
  """
  def post(conn, %{"name" => name}) do
    case Storage.lock(name) do
      :ok ->
        send_resp(conn, :accepted, "")
      {:error, "repo not found"} ->
        send_resp(conn, :not_found, "")
      {:error, reason} ->
        raise reason
    end
  end

  @doc """
  Unlock repo
  """
  def delete(conn, %{"name" => name}) do
    Storage.unlock(name)
    send_resp(conn, :accepted, "")
  end

  @doc """
  Check repo is locked?
  """
  def get(conn, %{"name" => name, "head"=> true}), do: get(conn, %{"name" => name})

  def get(conn, %{"name" => name}) do
    if Storage.locked?(name) do
      send_resp(conn, :ok, "")
    else
      send_resp(conn, :not_found, "")
    end
  end
end
