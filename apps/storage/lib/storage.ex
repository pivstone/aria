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
    target_name = Storage.PathSpec.get_blob_path(name, digest)
    driver().move(file_name, target_name)
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
     link = tag_current_path <> "/link"
     if not driver().exists?(link) do

     end
     digest = driver().read(link)
     manifest_path = Storage.PathSpec.get_blob_path(name,digest)
     driver().read(manifest_path)
  end

  def get_blob_size(name, digest) do
    blob_path = Storage.PathSpec.get_blob_path(name,digest)
    driver().size(blob_path)
  end
  @doc """
  创建上传的文件时候的 Blob 文件
  """
	def create_blob(_name) do
    32
    |> :crypto.strong_rand_bytes
    |> Base.encode16(case: :lower)
	end

  def get_repositories(keyword,count \\ 10) do
    prefix = Storage.PathSpec.data_dir()
    len = prefix |> String.length
    len = len + 1
    "#{prefix}/**/_uploads"
    |> driver().list([keyword])
    |> Enum.reduce([],fn(x,acc) -> [x |> String.slice(len..-10) |acc] end)
  end

	@doc """
	获取 Repo 的 tags
	"""
	def get_tags(name) do
		tag_path = Storage.PathSpec.get_tags_path(name)
    len = 1 + String.length(tag_path)
    "#{tag_path}/*"
    |> driver().list()
    |> Enum.reduce([],fn(x,acc) -> [x |> String.slice(len..-1) |acc] end)
	end

	def blob_stream(name, digest) do
	  blob_path = Storage.PathSpec.get_blob_path(name,digest)
    driver().stream(blob_path)
	end


	def get_blob(name, digest) do
	  blob_path = Storage.PathSpec.get_blob_path(name,digest)
    driver().read(blob_path)
	end


	def exists?(name,digest) do
	  blob_path = Storage.PathSpec.get_blob_path(name,digest)
    driver().exists?(blob_path)
	end


	def save_manifest(name,data)do
	  hash = :sha256
    digest = hash
    |> :crypto.hash_init
    |> :crypto.hash_update(data)
    |> :crypto.hash_final
    |> Base.encode16(case: :lower)

    digest_name = ~s(#{hash}) <> ":" <> digest
    target_name = Storage.PathSpec.get_blob_path(name,digest_name)
    driver().save(target_name,data)
    digest_name
	end

  @doc """
  Link Blob 到指定目录
  :param digest: sha256：XXX 格式的
  :param target:
  :return:
  """
  def link(digest, target) do
    path = target <> "/link"
    driver().save(path, digest)
  end
end
