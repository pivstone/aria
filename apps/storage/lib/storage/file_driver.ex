defmodule Storage.FileDriver do
	@moduledoc """
	File Base 的存储
	"""

	require Logger
  @behaviour Storage.Driver

	def create_blob(name) do
    upload_id = :crypto.strong_rand_bytes(16)|> Base.encode16
    file_name = Storage.PathSepc.get_upload_path(name, upload_id)
    ensure_dir(file_name)
    upload_id
	end

	def get_blob_digest(name, uuid, hash_method) when hash_method == "sha256" do
		uuid_path = Storage.PathSepc.get_upload_path(name,uuid)
		if not File.exists?(uuid_path) do
			Logger.warn "file #{uuid_path} not found"
			raise Storage.FileNotFoundError
		end
		File.stream!(uuid_path,[],4096)
		|> Enum.reduce(:crypto.hash_init(:sha256),fn(line, acc) -> :crypto.hash_update(acc,line) end )
		|> :crypto.hash_final
		|> Base.encode16
		|> String.downcase
	end

	def get_blob_digest(_name, _uuid, _hash_method) do
		raise "Not Support Hash Method"
	end

	def commit(name,uuid,digest) do
		file_name = Storage.PathSepc.get_upload_path(name, uuid)
		target_name = Storage.PathSepc.get_blob_path(name,digest)
		ensure_dir(file_name)
		ensure_dir(target_name)
		File.rename(file_name, target_name)
	end
	defp ensure_dir(file_name) do
    dir_name = Path.dirname(file_name)
    if not File.exists?(dir_name) do
        File.mkdir_p(dir_name)
		end
	end

	def get_repositories(keyword,count \\ 10) do
		prefix = Storage.PathSepc.data_dir()
		Path.wildcard("#{prefix}/**/_uploads",[keyword])
		|> Enum.slice(1..count)
		|> Enum.reduce([],fn(x,acc) ->
		  [x |> String.slice(length(prefix)..-8) |acc]
		end)
	end

	def save_full_upload(path, image_name, uuid) do
		file_name = Storage.PathSepc.get_upload_path(image_name, uuid)
		ensure_dir(file_name)
		File.rename(path, file_name)
		%{size: size} = File.stat! file_name
		size
	end
end