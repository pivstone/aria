defmodule Storage.FileDriver do
	@moduledoc """
	File Base 的存储
	"""

  @behaviour Storage.Driver

	def create_blob(name) do
    upload_id = :crypto.strong_rand_bytes(24)|> :base64.encode
    file_name = Storage.PathSepc.get_upload_path(name, upload_id)
    ensure_dir(file_name)
    upload_id
	end

	defp ensure_dir(file_name) do
    dir_name = Path.dirname(file_name)
    if not File.exists?(dir_name) do
        File.mkdir_p(dir_name)
		end
	end
end