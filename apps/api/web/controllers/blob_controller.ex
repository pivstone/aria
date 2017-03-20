defmodule Api.BlobController do
	use Api.Web, :controller
  require Logger

  @doc """
  获取 Blob 对象
  """
  def get(conn, %{"name" => name, "digest" => digest} = _params) do
    blob_path = Storage.PathSpec.get_blob_path(name, digest)
    send_file(conn, :ok, blob_path)
  end

  @doc """
  完成 Blob 上传流程。并进行必要的检查
  """

  def put(conn, %{"name" => name, "digest" => digest, "uuid" => uuid} =_params) do
    [hash_method, value] = digest |> String.split(":", parts: 2)
    file_digest = Storage.driver().get_blob_digest(name, uuid, hash_method)
    if value != file_digest do
      Logger.warn("Blob upload digest didnt match #{file_digest} != #{value}")
      raise Api.DockerError,message: "digest did not match uploaded content",
                            code: "BLOB_UPLOAD_INVALID",
                            plug_status: 400,
                            detail: %{}
    end
    Storage.driver().commit(name, uuid, digest)
    conn
      |> put_req_header("location", conn.request_path)
      |> put_req_header("docker-upload-uuid",uuid)
      |> send_resp(204, "")
  end
  @doc """
  检查 Blob 对象是否存在
  """

  def head(conn, %{"name" => name,"digest" => digest} = _params) do
    blob_path = Storage.PathSpec.get_blob_path(name,digest)
    if File.exists?(blob_path) do
      send_resp(conn, :ok, "")
    else
      send_resp(conn, :not_found, "")
    end
  end

  def patch(conn, %{"name" => name,  "uuid" => uuid, "_upload" => path} =_params) do
    len = Storage.driver().save_full_upload(path, name, uuid)
    conn
      |> put_req_header("location", conn.request_path <> uuid)
      |> put_req_header("docker-upload-uuid",uuid)
      |> put_req_header("range","0-#{len}")
      |> send_resp(202, "")
  end

  def post(conn, %{"uuid" => uuid} = _params) do
    conn
      |> put_req_header("location", conn.request_path)
      |> put_req_header("docker-upload-uuid",uuid)
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
    raise Api.DockerError,message: "invalid repository name",
                         code: "NAME_INVALID",
                         plug_status: 400,
                         detail: %{}
  end

  def init_upload(conn, %{"name" => name,"mount" => _mount } = _params) do
    upload_id = Storage.driver().create_blob(name)
    conn
    |> put_req_header("location", conn.request_path <> upload_id)
    |> put_req_header("docker-upload-uuid",upload_id)
    |> put_req_header("range","0-0")
    |> send_resp(201, "")
  end

  def init_upload(conn, %{"name" => name} = _params) do
    upload_id = Storage.driver().create_blob(name)
    conn
    |> put_resp_header("location", conn.request_path <> upload_id)
    |> put_resp_header("docker-upload-uuid",upload_id)
    |> put_resp_header("range","0-0")
    |> send_resp(202, "")
  end

  def delete(conn,_params) do
    render conn, "index.json",tag: []
  end
end