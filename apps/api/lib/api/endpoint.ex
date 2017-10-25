defmodule Api.Endpoint do
  use Phoenix.Endpoint, otp_app: :aria_api

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger
  plug Api.Plug.DefaultType
  plug Plug.Parsers,
    parsers: [Api.Parsers.Chunked, Api.Parsers.Schema1, Api.Parsers.Schema2, :urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Api.Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_api_key",
    signing_salt: "nrYQU0yb"

  plug Api.Router
end
