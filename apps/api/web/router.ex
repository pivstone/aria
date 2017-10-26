defmodule Api.Router do
  use Api.Web, :router
  use Plug.ErrorHandler
  require Logger

  pipeline :api do
    plug :accepts, ["octet-stream", "json", "manifest.v1-prettyjws", "manifest.v2-json", "manifest.v2.list-json"]
    plug Api.Plug.DockerHeader
    plug Api.Plug.Auth
  end

  scope "/", Api do
    pipe_through :api
    get    "/", ImageController, :index
    get    "/_catalog", CatalogController, :get
    get    "/*name", DockerRouter, :get
    post   "/*name", DockerRouter, :post
    put    "/*name", DockerRouter, :put
    delete "/*name", DockerRouter, :delete
    patch  "/*name", DockerRouter, :patch
  end


  def handle_errors(conn, %{reason: exception} = _assigns) do
    status = Core.Exception.status(exception)
    body = Core.Exception.body(exception)
    conn = exception
           |> Core.Exception.headers
           |> Enum.reduce(
                conn,
                fn (header, conn) ->
                  put_req_header(
                    conn,
                    header
                    |> elem(0),
                    header
                    |> elem(1)
                  ) end
              )
           |> send_resp(status, body)
           |> halt
    conn
  end
end
