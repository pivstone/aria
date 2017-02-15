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
  end

  scope "/v2", Api do
    pipe_through :api

    get    "/", PageController, :index
    get    "/_catalog", ImageController,:catalog
    get    "/*name",DockerRouter,:get
    post   "/*name",DockerRouter,:post
    put    "/*name",DockerRouter,:put
    head   "/*name",DockerRouter,:head
    delete "/*name",DockerRouter,:delete
    get    "/manifests/:reference", ManifestController,:show
    get    "/blobs／:digest", BlobController,:download
    get    "/blobs/uploads/:uuid", BlobController,:uploads
  end



  # Other scopes may use custom stacks.
  # scope "/api", Api do
  #   pipe_through :api
  # end
end
