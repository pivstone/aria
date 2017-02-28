defmodule Storage.Driver do
  @moduledoc """
  Documentation for Storage.
  """
  @doc """
  创建 Blob
  """

  @callback create_blob(String.t) :: String.t
end
