defmodule Api.Router do
  use Api.Web, :router
  use Plug.ErrorHandler
  require Logger

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["octet-stream", "json", "manifest.v1-prettyjws", "manifest.v2-json", "manifest.v2.list-json"]
    plug Api.Plug.DockerHeader
  end

  scope "/v2", Api do
    pipe_through :api
    get    "/",         ImageController,:index
    get    "/_catalog", ImageController,:catalog
    get    "/*name",    DockerRouter,   :get
    post   "/*name",    DockerRouter,   :post
    put    "/*name",    DockerRouter,   :put
    delete "/*name",    DockerRouter,   :delete
    patch  "/*name",    DockerRouter,   :patch
  end


  def handle_errors(conn, %{reason: %Docker.Exception{} = exception}) do
    reason = %{"errors" => [%{"code" => exception.code,
                             "message"=> exception.message,
                             "detail" => exception.detail}]}
    body = Poison.encode! reason
    conn
    |> put_req_header("content_type", "application/json")
    |> send_resp(conn.status,body)
  end

  def handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{} = _exception} = _assigns) do
    send_resp(conn, conn.status, "Not Found")
  end

  def handle_errors(conn, assigns) do
    Logger.warn(inspect assigns)
    send_resp(conn, conn.status, "Something went wrong")
  end

end
