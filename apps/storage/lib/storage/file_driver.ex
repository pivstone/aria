defmodule Storage.FileDriver do
	@moduledoc """
	File Base 的存储
	"""

  @behaviour Storage.Driver

	def create_blob(name) do
    upload_id = :crypto.strong_rand_bytes(16)|> Base.encode16
    file_name = Storage.PathSepc.get_upload_path(name, upload_id)
    ensure_dir(file_name)
    upload_id
	end

	def get_blob_digest(name, uuid, hash_method) when hash_method == "sha256" do
		uuid_path = Storage.PathSepc.get_upload_path(name,uuid)
		File.stream!(uuid_path,[],4096)
		|> Enum.reduce(:crypto.hash_init(:sha256),fn(line, acc) -> :crypto.hash_update(acc,line) end )
		|> :crypto.hash_final |> Base.encode16
	end

	def get_blob_digest(_name, _uuid, _hash_method) do
		raise "Not Support Hash Method"
	end

	def commit(name,uuid,digest) do
		file_name = Storage.PathSepc.get_upload_path(name, uuid)
		target_name = Storage.PathSepc.get_blob_path(digest, name)
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
end