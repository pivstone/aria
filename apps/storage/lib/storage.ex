defmodule Storage do
  @moduledoc """
  Documentation for Storage.
  """
  @default_driver Storage.FileDriver
  def driver do
    Application.get_env(:storage, __MODULE__, [])[:driver]||@default_driver
  end


  @doc """
  获取 Blob 文件的 Digest 值
  """
  def get_blob_digest(name, uuid, hash_method) when hash_method == "sha256" do
    uuid_path = Storage.PathSpec.get_upload_path(name,uuid)
    driver().digest(uuid_path)
  end

  def get_blob_digest(_name, _uuid, _hash_method) do
    raise "Not Support Hash Method"
  end

  def commit(name,uuid,digest) do
    file_name = Storage.PathSpec.get_upload_path(name, uuid)
    target_name = Storage.PathSpec.get_blob_path(name,digest)
    driver().move(file_name,target_name)
  end

  @doc """
  保存 Blob 对象
  """
  def save_full_upload(tmp_path, name, uuid) do
    file_name = Storage.PathSpec.get_upload_path(name, uuid)
    driver().move(tmp_path, file_name)
    driver().size(file_name)
  end

  def get_manifest(name, "sha256:"<> digest) do
    manifest_path = Storage.PathSpec.get_blob_path(name, "sha256:"<> digest)
    # TODO:add manifest check
    driver().read(manifest_path)
  end

  def get_manifest(name,  reference) do
     tag_current_path = Storage.PathSpec.get_tag_current_path(name, reference)
     digest = driver().read(tag_current_path <> "/link")
     manifest_path = Storage.PathSpec.get_blob_path(name,digest)
     driver().read(manifest_path)
  end


  @doc """
  创建上传的文件时候的 Blob 文件
  """
	def create_blob(_name) do
    :crypto.strong_rand_bytes(16)|> Base.encode16
	end

  def get_repositories(keyword,count \\ 10) do
    prefix = Storage.PathSpec.data_dir()
    len = prefix |> String.length
    driver().list("#{prefix}/**/_uploads",[keyword])
    |> Enum.slice(1..count)
    |> Enum.reduce([],fn(x,acc) ->
      [x |> String.slice(len ..-8) |acc]
    end)
  end

	@doc """
	获取 Repo 的 tags
	"""
	def get_tags(name) do
		tag_path = Storage.PathSpec.get_tags_path(name)
    len = 1 + String.length(tag_path)
    driver().list("#{tag_path}/*")
    |> Enum.reduce([],fn(x,acc) ->
      [x |> String.slice(len..-1) |acc]
    end)
	end

	def blob_stream(name, digest) do
	  blob_path = Storage.PathSpec.get_blob_path(name,digest)
    driver().stream(blob_path)
	end
end
