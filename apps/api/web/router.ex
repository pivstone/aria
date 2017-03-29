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
    plug :accepts, ["json"]
    plug Plug.Parsers, parsers: [:urlencoded, :json,Api.Parsers.Chunked]
    plug Plug.Head
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

  def handle_errors(conn, %{reason: %Api.DockerError{} = exception}) do
    reason = %{"errors" => [%{"code" => exception.code,
                             "message"=> exception.message,
                             "detail" => exception.detail}]}
    body = Poison.encode! reason
    conn
    |> put_req_header("content_type", "application/json")
    |> send_resp(conn.status,body)
  end

  def handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{} = exception}=_assigns) do
    send_resp(conn, conn.status, "Not Found")
  end

  def handle_errors(conn, assigns) do
    Logger.warn inspect "uncatch exception #{assigns}"
    send_resp(conn, conn.status, "Something went wrong")
  end

end
