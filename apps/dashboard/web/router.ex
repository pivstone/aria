defmodule Dashboard.Router do
  use Dashboard.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/images", Dashboard do
    pipe_through :api
    get "/manifest", RepoController, :manifest
    get "/", RepoController, :list
    get "/:name", RepoController, :retrieve
  end
end
