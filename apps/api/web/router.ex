defmodule Api.Router do
  use Api.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Plug.Head
  end

  scope "/v2", Api do
    pipe_through :api

    get    "/",         PageController, :index
    get    "/_catalog", ImageController,:catalog
    get    "/*name",    DockerRouter,   :get
    post   "/*name",    DockerRouter,   :post
    put    "/*name",    DockerRouter,   :put
    delete "/*name",    DockerRouter,   :delete
    patch  "/*name",    DockerRouter,   :patch
  end

end
