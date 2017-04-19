defmodule Api.Plug.DefaultType do
  @moduledoc """
  Add default content-type(application/octet-stream) to request
  ## Examples
      Plug.DefaultType.call(conn, [])
  """

  @behaviour Plug
  @methods ~w(POST PUT PATCH DELETE)
  alias Plug.Conn

  def init([]), do: []

  def call(%{req_headers: [{"content-type",""},rest]= _req_headers, method: method} = conn, [])
    when method  in @methods  do
    new_req_headers = [{"content-type","application/octet-stream"}|rest]
    %{conn | req_headers: new_req_headers }
  end

  def call(%{req_headers: req_headers, method: method} = conn, [])
    when method  in @methods  do
    new_req_headers = [{"content-type","application/octet-stream"}|req_headers]
    %{conn | req_headers: new_req_headers }
  end

  def call(conn, []), do: conn
end