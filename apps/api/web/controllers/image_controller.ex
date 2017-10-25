defmodule Api.ImageController do
  use Api.Web, :controller
  require Logger

  def index(conn,   _params) do
    render conn, "index.json", %{}
  end

  @doc """
  Delete repo
  """
  def delete(conn, %{"name" => name}) do
    case Storage.delete_repo(name) do
      {:ok, _result} ->
        send_resp(conn, :accepted, "")
      {:error, "repo didn't locked"} ->
        send_resp(conn, :not_acceptable, "repo didn't locked")
      {:error, reason} ->
        raise reason
    end
  end

  def get(conn, %{"name" => name}) do
    raise Storage.Exception,
      message: "repository not found",
      code: "REPOSITORY_NOT_FOUND",
      plug_status: 404,
      detail: %{"name" => name}
  end
end
