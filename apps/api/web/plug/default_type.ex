defmodule Api.Plug.DefaultType do
  @moduledoc """
  Add default content-type(application/octet-stream) to request
  ## Examples
      Plug.DefaultType.call(conn, [])
  """

  @behaviour Plug
  @methods ~w(POST PUT PATCH DELETE)
  @empty_type {"content-type", ""}
  @chunked_type {"transfer-encoding", "chunked"}

  def init([]), do: []

  def call(%{method: method, req_headers: req_headers} = conn, []) when method  in @methods do
    @chunked_type in req_headers &&  _call(conn) || conn
  end

  def call(conn, []), do: conn

  defp _call(%{req_headers: req_headers} = conn) do
    rest = @empty_type in req_headers && List.delete(req_headers, @empty_type) || req_headers
    new_req_headers = [{"content-type", "application/octet-stream"}|rest]
    %{conn | req_headers: new_req_headers}
  end
end