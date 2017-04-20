defmodule Api.Plug.DockerHeader do
  @moduledoc """
  A Plug to convert `HEAD` requests to `GET` requests.

  ## Examples

      Plug.Head.call(conn, [])
  """

  @behaviour Plug
  alias Plug.Conn
  def init([]), do: []

  def call(conn, [])  do
	  Conn.register_before_send(conn, fn conn ->
      digest = :sha256
        |> :crypto.hash_init
        |> :crypto.hash_update(conn.resp_body||"")
        |> :crypto.hash_final
        |> Base.encode16(case: :lower)
      conn
        |> Conn.put_resp_header("docker-content-digest", "sha256:"<>digest)
        |> Conn.put_resp_header("x-content-type-options","nosniff")
        |> Conn.put_resp_header("docker-distribution-api-version","registry/2.0")
		end)
  end
end
