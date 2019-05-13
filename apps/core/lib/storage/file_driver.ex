defmodule Storage.FileDriver do
  @moduledoc """
  Local File Driver
  """

  require Logger
  @behaviour Storage.Driver

  @type path :: String.t
  @doc """
  File move
  """
  def move(src, dist) do
    ensure_dir(dist)
    # TODO:  add move test in docker
    with :ok <- File.cp!(src, dist),
         :ok <- src
                |> File.rm!,
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
  Return file's SHA256 value
  """
  def digest(path) do
    check_file(path)
    path
    |> File.stream!([], 4096)
    |> Enum.reduce(:crypto.hash_init(:sha256), fn (line, acc) -> :crypto.hash_update(acc, line) end)
    |> :crypto.hash_final
    |> Base.encode16(case: :lower)
  end

  @doc """
  Return size of file
  """
  def size(path), do: size(path, File.dir?(path))

  def size(path, false) do
    check_file(path)
    %{size: size} = File.stat! path
    size
  end

  @doc """
  Return size of directoy
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
  Read file content
  """
  def read(path) do
    check_file(path)
    File.read!(path)
  end

  @doc """
  Check the file exitsts or not
  """
  def exists?(path), do: File.exists?(path)

  @doc """
  Return File IO Stream
  """
  def stream(path) do
    check_file(path)
    File.stream!(path, [], 4096)
  end

  @doc """
  List of directory
  """
  def list(path), do: Path.wildcard(path)

  def list(path, keyword) when is_binary(keyword), do: Path.wildcard(path, [keyword])

  @doc """
  Check if the file is exist
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
  Save data to file
  """
  def save(path, data) do
    ensure_dir(path)
    File.write!(path, data)
  end

  def delete(path), do: File.rm_rf(path)
end
