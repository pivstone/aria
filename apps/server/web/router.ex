defmodule Server.Router do
  use Server.Web, :router
  use Plug.ErrorHandler

  forward "/v2", Api.Router
  forward "/api", Dashboard.Router

  def handle_errors(conn, %{reason: exception} = _assigns) do
    status = Core.Exception.status(exception)
    body = Core.Exception.body(exception)
    exception
    |> Core.Exception.headers
    |> Enum.reduce(conn,fn(header,conn) -> put_req_header(conn, header|>elem(0), header |> elem(1)) end)
    |> send_resp(status, body)
  end
end