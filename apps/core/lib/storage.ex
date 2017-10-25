defmodule Storage do
  @moduledoc """
  Documentation for Storage.
  """
  require Logger

  @default_driver Storage.FileDriver
  def driver do
    Application.get_env(:aria_core, __MODULE__, [])[:driver] || @default_driver
  end

  @doc """
  获取 Blob 文件的 Digest 值
  """
  def get_blob_digest(name, uuid, hash_method) when hash_method == "sha256" do
    uuid_path = Storage.PathSpec.get_upload_path(name, uuid)
    driver().digest(uuid_path)
  end

  def get_blob_digest(_name, _uuid, _hash_method) do
    raise "Not Support Hash Method"
  end

  @doc """
  Remove specified tag from repo via *digest*
  """
  def untag(name,"sha256:" <> _ = digest) do
    raise Storage.Exception,
      message: "operation is not supported yet.",
      code: "OPTS_NOT_SUPPORTED",
      plug_status: 405
    # TODO: delete revision_path
    # TODO: Fetch all tags
    # TODO: check tags link value
    # TODO: remove linked tags
  end

  @doc """
  Remove specified tag from repo via *tag name*
  """
  def untag(name, reference) do
    name
    |> Storage.PathSpec.get_tag_path(reference)
    |> driver().delete
  end

  @doc """
  Verify Blob
  """

  def verify(name, digest) do
    if not exists?(name, digest) do
      Logger.warn(fn -> "manifest:#{name} verify failed cause:layer:#{digest} length is zero" end)
      raise Storage.Exception,
        message: "blob unknown to registry",
        code: "BLOB_UNKNOWN",
        plug_status: 400
    end
    verify_digest(name,digest)
  end

  defp verify_digest(name, "sha256:" <> except_digest = digest) do
    path = Storage.PathSpec.get_blob_path(name, digest)
    if except_digest != driver().digest(path) do
      Logger.warn(fn -> "manifest:#{name} verify failed cause:layer:#{digest} invalid" end)
      raise Storage.Exception,
       message: "manifest unverified",
       code: "MANIFEST_UNVERIFIED",
       plug_status: 400
    end
  end

  def commit(name, uuid, digest) do
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

  def get_manifest(name, reference) do
    tag_current_path = Storage.PathSpec.get_tag_current_path(name, reference)
    link = tag_current_path <> "/link"
    if not driver().exists?(link) do
      raise Storage.Exception,
        message: "manifest unknown",
        code: "MANIFEST_UNKNOWN",
        plug_status: 404,
        detail: %{"Name" => name, "Tag" => reference}
    end
    digest = driver().read(link)
    manifest_path = Storage.PathSpec.get_blob_path(name, digest)
    driver().read(manifest_path)
  end
  @doc """
  ### Example
    iex> Storage.get_blob_size("registry", "sha256:3cc64cc451428c45615c1c5a5fe7533f336f2cac22095774a073b61a596b987f")
    1287
    iex> Storage.get_blob_size("registry2", "sha256:3cc64cc451428c45615c1c5a5fe7533f336f2cac22095774a073b61a596b987f")
    ** (Storage.Exception) blob unknown
  """
  def get_blob_size(name, digest) do
    blob_path = Storage.PathSpec.get_blob_path(name, digest)
    driver().size(blob_path)
  end

  @doc """
  ### Example
    iex> Storage.get_repo_size("registry")
    10480
    iex> Storage.get_repo_size("abc")
    ** (Storage.Exception) blob unknown
  """
  def get_repo_size(name) do
    repo_path = Storage.PathSpec.get_repo_path(name)
    driver().size(repo_path)
  end

  @doc """
  创建上传的文件时候的 Blob 文件
  """
    def create_blob(_name) do
    32
    |> :crypto.strong_rand_bytes
    |> Base.encode16(case: :lower)
    end

  @doc ~s"""
  ### Example
    iex> Storage.get_repositories("")
    ["test/test", "registry"]
    iex> Storage.get_repositories("test")
    ["test/test"]
    iex> Storage.get_repositories("abc")
    []
  """
  def get_repositories(keyword) do
    prefix = Storage.PathSpec.data_dir
    len = prefix |> String.length
    len = len + 1
    "#{prefix}/#{keyword}*/**/_manifests"
    |> driver().list()
    |> Enum.reduce([], fn(x, acc) -> [x |> String.slice(len..-12) |acc] end)
  end

  def get_repositories(keyword, count) do
    prefix = Storage.PathSpec.data_dir
    len = prefix |> String.length
    len = len + 1
   "#{prefix}/#{keyword}*/**/_uploads"
    |> driver().list()
    |> Enum.slice(0..count)
    |> Enum.reduce([], fn(x, acc) -> [x |> String.slice(len..-10) |acc] end)
  end

  @doc ~s"""
  ### Example
    iex> Storage.get_tags("registry")
    ["latest"]
    iex> Storage.get_repositories("abc")
    []
  """
  def get_tags(name) do
    tag_path = Storage.PathSpec.get_tags_path(name)
    if not driver().exists?(tag_path) do
      raise Storage.Exception,
         message: "repository not found",
         code: "REPOSITORY_NOT_FOUND",
         plug_status: 404
    end
    len = 1 + String.length(tag_path)
    "#{tag_path}/*"
      |> driver().list
      |> Enum.reduce([], fn(x, acc) -> [x |> String.slice(len..-1) |acc] end)
  end

  def blob_stream(name, digest) do
    blob_path = Storage.PathSpec.get_blob_path(name, digest)
    driver().stream(blob_path)
  end

  def get_blob(name, digest) do
    blob_path = Storage.PathSpec.get_blob_path(name, digest)
    driver().read(blob_path)
  end

  @doc ~S"""
  Return `true` if blob exisit.
  ### Example
    iex> Storage.exists?("test/test", "sha256:0067e2ebd5851ce0052b01465883b3e16885bb3e362a7e5617243688ed5eca75")
    true

    iex> Storage.exists?("registry", "sha256:0067e2ebd5851ce0052b01465883b3e16885bb3e362a7e5617243688ed5eca75")
    false
  """
  def exists?(name, digest) do
    blob_path = Storage.PathSpec.get_blob_path(name, digest)
    driver().exists?(blob_path)
  end

  @doc """
  Return `true` if repo exisit
  ### Example
    iex> Storage.exists?("registry")
    true

    iex> Storage.exists?("registry2")
    false
  """
  def exists?(name) do
    name
    |> Storage.PathSpec.get_tags_path()
    |> driver().exists?()
  end

  def save_manifest(name, data)do
    hash = :sha256
    digest = hash
    |> :crypto.hash_init
    |> :crypto.hash_update(data)
    |> :crypto.hash_final
    |> Base.encode16(case: :lower)

    digest_name = ~s(#{hash}) <> ":" <> digest
    target_name = Storage.PathSpec.get_blob_path(name, digest_name)
    driver().save(target_name, data)
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

  @doc ~S"""
  锁定镜像，进入只读模式
  ### Example
    iex> Storage.locked?("registry")
    false
    iex> Storage.lock("registry")
    iex> :ok
    iex> Storage.locked?("registry")
    true
    iex> Storage.locked?("registry2")
    false
    iex> Storage.lock("aaa")
    {:error,"repo not found"}
  """
  def lock(name) do
   if exists?(name) do
    name |> Storage.PathSpec.get_lock_file |> driver().save(<<"">>)
   else
    {:error,"repo not found"}
   end
 end
  @doc ~s"""
  解除锁定镜像
  ### Example
    iex> Storage.locked?("test/test")
    false
    iex> Storage.lock("test/test")
    :ok
    iex> Storage.locked?("test/test")
    true
    iex> Storage.unlock("test/test")
    {:ok ,["#{Storage.PathSpec.data_dir()}/test/test/.lock"]}
    iex> Storage.locked?("test/test")
    false
  """
  def unlock(name), do: name |> Storage.PathSpec.get_lock_file |> driver().delete()

  @doc ~S"""
  Return `true` if the repo is locked
  """
  def locked?(name), do: name |> Storage.PathSpec.get_lock_file |> driver().exists?()

  @doc ~s"""
  Delete the repo
  ### Example
    iex> Storage.exists?("example")
    true
    iex> Storage.delete_repo("example")
    {:error, "repo didn't locked"}
    iex> Storage.lock("example")
    :ok
    iex> Storage.delete_repo("example")
    {:ok,["#{Storage.PathSpec.data_dir()}/example", "#{Storage.PathSpec.data_dir()}/example/_manifests",
                 "#{Storage.PathSpec.data_dir()}/example/_manifests/tags", "#{Storage.PathSpec.data_dir()}/example/.lock"]}
    iex> Storage.exists?("example")
    false
  """
  def delete_repo(name) do
    if locked?(name) do
      name
      |> Storage.PathSpec.get_repo_path()
      |> driver().delete()
    else
      {:error, "repo didn't locked"}
    end
  end
end
