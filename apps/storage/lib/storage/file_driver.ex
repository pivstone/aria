defmodule Storage.FileDriver do
	@moduledoc """
	File Base 的存储
	"""

	require Logger
  @behaviour Storage.Driver

	def move(src,dist) do
    ensure_dir(dist)
    with :ok <- File.rename(src, dist),
         :ok <- src|> Path.dirname |> File.rmdir!,
    do: :ok
	end

	defp ensure_dir(file_name) do
    dir_name = Path.dirname(file_name)
    if not File.exists?(dir_name) do
        File.mkdir_p(dir_name)
    end
  end

  def digest(path) do
    check_file(path)
    path
    |> File.stream!([],4096)
    |> Enum.reduce(:crypto.hash_init(:sha256),fn(line, acc) -> :crypto.hash_update(acc,line) end )
    |> :crypto.hash_final
    |> Base.encode16
    |> String.downcase
  end

  def size(path) do
    check_file(path)
    %{size: size} = File.stat! path
    size
  end

  def read(path) do
    check_file(path)
    File.read!(path)
  end
  def exist?(path), do: File.exists?(path)

  def stream(path) do
    check_file(path)
    File.stream!(path,[],4096)
  end
  def list(path), do:  Path.wildcard(path)

  def list(path,keyword),do: Path.wildcard(path,[keyword])


  def check_file(path) do
    if not File.exists?(path) do
      raise Storage.FileError,
        message: "blob unknown",
        code: "BLOB_UNKNOWN",
        plug_status: 404
    end
  end
end