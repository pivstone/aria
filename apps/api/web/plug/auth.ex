defmodule Api.Plug.Auth do
  @moduledoc """
  Auth check
  """

  @behaviour Plug
  def init([]), do: []

  def call(conn, [])  do
    Api.Auth.authenticate(conn)
  end
end
