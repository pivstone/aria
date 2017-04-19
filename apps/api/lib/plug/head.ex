defmodule Api.Plug.Head do
  @moduledoc """
  A Plug to convert `HEAD` requests to `GET` requests.

  ## Examples

      Plug.Head.call(conn, [])
  """

  @behaviour Plug

  alias Plug.Conn
  def init([]), do: []

  def call(%Conn{method: "HEAD"} = conn, [])  do
    conn = update_in conn.params ,&Map.merge(&1,%{"head"=>true})
	  %{conn | method: "GET"}
  end
  def call(conn, []), do: conn
end
