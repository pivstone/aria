defmodule Storage.Driver do
  @moduledoc """
  Documentation for Storage.
  """


  @type image_name :: String.t
  @type uuid :: String.t
  @type digest :: String.t

  @doc """
  创建 Blob
  """
  @callback create_blob(image_name) :: String.t

  @doc """
  获取 Blob 的 digest
  """
  @callback get_blob_digest(image_name, uuid, hash_method :: String.t) :: String.t

  @doc """
  提交 upload 文件
  """
  @callback commit(image_name, uuid, digest) :: none

  @doc """
  查找 Repo
  """
  @callback get_repositories(keyword :: String.t, count :: number) :: [String.t]

  @doc """
  存储上传文件
  """
  @callback save_full_upload(path :: String.t, image_name, uuid) :: number
end
