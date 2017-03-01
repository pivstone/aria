defmodule Storage.Driver do
  @moduledoc """
  Documentation for Storage.
  """


  @type image_name :: String.t

  @doc """
  创建 Blob
  """
  @callback create_blob(image_name) :: String.t

  @doc """
  获取 Blob 的 digest
  """
  @callback get_blob_digest(image_name, String.t, String.t) :: String.t
end
