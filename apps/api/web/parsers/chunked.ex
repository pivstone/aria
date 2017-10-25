defmodule Api.Parsers.Chunked do
  @moduledoc """
  Docker Chunked Upload Parse
  """

  @behaviour Plug.Parsers
  import Plug.Conn
  @workdir "#{System.tmp_dir}/aria/_upload"

  def parse(conn, "application", "octet-stream", _headers, _opts) do
    file = make_random_file_path()
    conn
    |> read_body
    |> save(file)
  end

  def parse(conn, _type, _subtype, _headers, _opts) do
    {:next, conn}
  end

  defp make_random_file_path do
    {_mega, sec, micro} = :os.timestamp
    scheduler_id = :erlang.system_info(:scheduler_id)
    random_name =
      16
      |> :crypto.strong_rand_bytes
      |> Base.url_encode64
      |> binary_part(0, 16)
    path = "#{@workdir}-#{sec}-#{micro}-#{scheduler_id}/"
    case File.mkdir_p(path) do
       :ok ->
         path <> random_name
       {:error, reason} ->
        raise reason
    end
  end

  defp save({:ok, body, conn}, path) do
    File.write!(path, body, [:write, :raw, :binary, :append])
    {:ok, %{"_upload" => path}, conn}
  end

  defp save({:more, body, conn}, path) do
    File.write!(path, body, [:write, :raw, :binary, :append])
    conn
      |> read_body
      |> save(path)
  end

  defp save({:error, _reason}, _path) do
    raise Plug.BadRequestError
  end
end
