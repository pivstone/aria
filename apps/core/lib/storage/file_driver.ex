defmodule Storage.FileDriver do
  @moduledoc """
  File Base 的存储
 """

  require Logger
  @behaviour Storage.Driver

  @doc """
  文件移动
  """
  def move(src, dist) do
    ensure_dir(dist)
    # TODO:  add move test in docker
    with :ok <- File.cp!(src, dist),
       :ok <- src |> File.rm!,
    do: :ok
  end

  defp ensure_dir(file_name) do
    dir_name = Path.dirname(file_name)
    if not File.exists?(dir_name) do
      case File.mkdir_p(dir_name) do
        :ok -> :ok
        {:error, :enametoolong} ->
          Logger.error(inspect "#{file_name} too long")
        {:error, reason} ->
          Logger.error(inspect "#{file_name} check failed, reason:#{reason}")
      end
    end
  end

  @doc """
  获取文件的 sha256 值
  """
  def digest(path) do
    check_file(path)
    path
    |> File.stream!([], 4096)
    |> Enum.reduce(:crypto.hash_init(:sha256), fn(line, acc) -> :crypto.hash_update(acc, line) end)
    |> :crypto.hash_final
    |> Base.encode16(case: :lower)
  end

  @doc """
  获取文件大小
  """
  def size(path) do
    size(path, File.dir?(path))
  end

  def size(path, false) do
    check_file(path)
    %{size: size} = File.stat! path
    size
  end

  @doc """
  获取文件夹大小
  """
  def size(path, true) do
    case System.cmd("du", ["-sk", "#{path}"], [stderr_to_stdout: true]) do
      {result, 0} ->
        result
        |> String.split
        |> Enum.at(0)
        |> String.to_integer
      {"du:" <> reason, 1} ->
        raise Storage.Exception,
          message: "folder size stat error",
          code: "FOLDER_SIZE_STAT_ERROR",
          plug_status: 400,
          detail: reason
    end
  end

  @doc """
  获取文件内容
  """
  def read(path) do
    check_file(path)
    File.read!(path)
  end

  @doc """
  检查文件是否存在
  """
  def exists?(path), do: File.exists?(path)

  @doc """
  获取文件流
  """
  def stream(path) do
    check_file(path)
    File.stream!(path, [], 4096)
  end

  @doc """
  List 目录
  """
  def list(path), do:  Path.wildcard(path)

  def list(path, keyword), do: Path.wildcard(path, [keyword])

  @doc """
  检查文件是否存在
  """
  def check_file(path) do
    if not File.exists?(path) do
      Logger.warn(path)
      raise Storage.Exception,
        message: "blob unknown",
        code: "BLOB_UNKNOWN",
        plug_status: 404
    end
  end

  @doc """
  文件存储
  """
  def save(path, data) do
    ensure_dir(path)
    File.write!(path, data)
  end

  def delete(path), do: File.rm_rf(path)
end