defmodule Api.BlobController do
  use Api.Web, :controller
  require Logger


  @doc """
  检查 Blob 对象是否存在
  """
  def get(conn, %{"name" => name, "digest" => digest, "head"=> true} = _params) do
    if Storage.exists?(name, digest) do
      content_len = Storage.blob_size(name, digest)
      conn
      |> put_resp_header("content-length", ~s(#{content_len}))
      |> send_resp(:ok, "")
    else
      Logger.warn(inspect "#{name},#{digest} not found")
      send_resp(conn, :not_found, "")
    end
  end

  @doc """
  获取 Blob 对象
  """
  def get(conn, %{"name" => name, "digest" => digest} = _params) do
    if Storage.exists?(name, digest) do
      conn = send_chunked(conn, 200)
      Enum.into(Storage.blob_stream(name, digest), conn)
    else
      send_resp(conn, :not_found, "")
    end
  end

  def post(conn, %{"uuid" => uuid} = _params) do
    conn
      |> put_resp_header("location", conn.request_path)
      |> put_resp_header("docker-upload-uuid", uuid)
      |> send_resp(204, "")
  end


  def delete(_conn, _params) do
    raise Storage.Exception,
     message: "The operation is unsupported",
     code: "UNSUPPORTED",
     plug_status: 405,
     detail: %{}
  end
end
