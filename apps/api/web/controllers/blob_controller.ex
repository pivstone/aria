defmodule Api.BlobController do
	use Api.Web, :controller
  require Logger

  @doc """
  检查 Blob 对象是否存在
  """
  def get(conn, %{"name" => name, "digest" => digest,"head"=> true} = _params) do
    if Storage.exists?(name,digest) do
      content_len = Storage.get_blob_size(name,digest)
      conn
      |> put_resp_header("content-length",~s(#{content_len}))
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
    if Storage.exists?(name,digest) do
      conn = send_chunked(conn, 200)
      Enum.into(Storage.blob_stream(name,digest),conn)
    else
      send_resp(conn, :not_found, "")
    end
  end




  @doc """
  完成 Blob 上传流程。并进行必要的检查
  """

  def put(conn, %{"name" => name, "digest" => digest, "uuid" => uuid} =_params) do
    [hash_method, value] = digest |> String.split(":", parts: 2)
    file_digest = Storage.get_blob_digest(name, uuid, hash_method)
    if value != file_digest do
      Logger.warn("Blob upload digest didnt match #{file_digest} != #{value}")
      raise Api.DockerError,
        message: "digest did not match uploaded content",
        code: "BLOB_UPLOAD_INVALID",
        plug_status: 400,
        detail: %{}
    end
    Storage.commit(name, uuid, digest)
    conn
      |> put_resp_header("location", conn.request_path<>"?"<>conn.query_string)
      |> put_resp_header("docker-upload-uuid",uuid)
      |> send_resp(204, "")
  end



  def patch(conn, %{"name" => name,  "uuid" => uuid, "_upload" => path} =_params) do
    len = Storage.save_full_upload(path, name, uuid)
    conn
      |> put_resp_header("location", conn.request_path)
      |> put_resp_header("docker-upload-uuid",uuid)
      |> put_resp_header("range","0-#{len}")
      |> send_resp(202, "")
  end

  def post(conn, %{"uuid" => uuid} = _params) do
    conn
      |> put_resp_header("location", conn.request_path)
      |> put_resp_header("docker-upload-uuid",uuid)
      |> send_resp(204, "")
  end

  @doc """
  /v2/<name>/blobs/uploads/
  开始上传 Blob 的准备
  :param request: Http 请求对象
  :param name: 镜像名
  """
  def init_upload(_conn, %{"name" => name} = _params) when byte_size(name) > 256 do
    Logger.warn("Image name invalid : #{name}")
    raise Api.DockerError,
      message: "invalid repository name",
       code: "NAME_INVALID",
       plug_status: 400,
       detail: %{}
  end

  def init_upload(conn, %{"name" => name,"mount" => _mount } = _params) do
    upload_id = Storage.create_blob(name)
    conn
    |> put_resp_header("location", conn.request_path <> upload_id)
    |> put_resp_header("docker-upload-uuid",upload_id)
    |> put_resp_header("range","0-0")
    |> send_resp(201, "")
  end

  def init_upload(conn, %{"name" => name} = _params) do
    upload_id = Storage.create_blob(name)
    conn
    |> put_resp_header("location", conn.request_path <> upload_id)
    |> put_resp_header("docker-upload-uuid",upload_id)
    |> put_resp_header("range","0-0")
    |> send_resp(202, "")
  end

  def delete(conn,_params) do
    raise Api.DockerError,message: "The operation is unsupported",
                         code: "UNSUPPORTED",
                         plug_status: 405,
                         detail: %{}
  end
end