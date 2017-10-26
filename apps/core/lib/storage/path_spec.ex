defmodule Storage.PathSpec do
  @moduledoc """
  Docker Registry 的文件存储结构
  ref:[https://github.com/docker/distribution/blob/641f1029677e49faa277f7769797518e973865fd/registry/storage/paths.go#L24]
  The path layout in the storage backend is roughly as follows:

  <root>/v2
       -> repositories/
           -><name>/
               -> _manifests/
                   revisions
                       -> <manifest digest path>
                           -> link
                   tags/<tag>
                       -> current/link
                       -> index
                           -> <algorithm>/<hex digest>/link
               -> _layers/
                   <layer links to blob store>
               -> _uploads/<id>
                   data
                   startedat        # 上传文件的时间而已，个人觉得改成 Info 更合适一些
                   hashstates/<algorithm>/<offset>
       -> blob/<algorithm>
           <split directory content addressable storage>

  Aira 的文件存储结构
  <root>/<name>
    -> _manifests/
            revisions
                -> <manifest digest path>
                    -> link
            tags/<tag>
                -> current/link
                -> index
                    -> <algorithm>/<hex digest>/link

        -> _blob/<algorithm>
            <split directory content addressable storage>
  """
  def data_dir do
    Application.fetch_env!(:core, __MODULE__)[:data_dir]
  end

  @doc """
  上传文件的临时路径
  :param name:
  :param uuid:
  :return:
  """
  def upload_path(name, uuid) do
    "#{data_dir()}/#{name}/_uploads/#{uuid}/data"
  end

  @doc """
  上传完成后的 blob 路径
  :param digest:
  :param name: repository name
  :return:
  """
  def blob_path(name, digest) do
    [hash_method, digest_value] = digest
                                  |> String.split(":", parts: 2)
    "#{data_dir()}/#{name}/_blob/#{hash_method}/#{
      digest_value
      |> String.slice(0..1)
    }/#{digest_value}/data"
  end

  def tags_path(name) do
    "#{data_dir()}/#{name}/_manifests/tags"
  end

  @doc """
  获取指定 tag 文件的路径
  :param name: image name
  :param tag_name: tag name
  :return:
  """
  def tag_path(name, tag_name) do
    "#{data_dir()}/#{name}/_manifests/tags/#{tag_name}"
  end

  def tag_current_path(name, tag_name) do
    "#{data_dir()}/#{name}/_manifests/tags/#{tag_name}/current"
  end

  def tag_index_path(name, tag_name, digest) do
    [hash_method, hash_value] = digest
                                |> String.split(":", parts: 2)
    "#{data_dir()}/#{name}/_manifests/tags/#{tag_name}/index/#{hash_method}/#{hash_value}"
  end

  def reference_path(name, digest) do
    [hash_method, hash_value] = digest
                                |> String.split(":", parts: 2)
    "#{data_dir()}/#{name}/_manifests/revisions/#{hash_method}/#{hash_value}"
  end

  def repo_path(name) do
    "#{data_dir()}/#{name}"
  end

  def lock_file(name) do
    "#{data_dir()}/#{name}/.lock"
  end
  @doc """
  获取需要删除的数据路径
  """
  def delete_path(name) do
    [
      "#{data_dir()}/#{name}/_manifests",
      "#{data_dir()}/#{name}/_blob",
      "#{data_dir()}/#{name}/_uploads",
      "#{data_dir()}/#{name}/.lock",
    ]
  end
end