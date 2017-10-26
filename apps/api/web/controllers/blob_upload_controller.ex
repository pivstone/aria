defmodule Api.BlobUploadController do
  use Api.Web, :controller
  require Logger

  @doc """
  完成 Blob 上传流程。并进行必要的检查
  """
  def put(conn, %{"name" => name, "digest" => digest, "uuid" => uuid} = _params) do
    locked(name)
    [hash_method, value] = digest |> String.split(":", parts: 2)
    file_digest = Storage.blob_digest(name, uuid, hash_method)
    if value != file_digest do
      Logger.warn(fn -> "Blob upload digest didnt match #{file_digest} != #{value}" end)
      raise Storage.Exception,
        message: "digest did not match uploaded content",
        code: "BLOB_UPLOAD_INVALID",
        plug_status: 400,
        detail: %{}
    end
    Storage.commit(name, uuid, digest)
    conn
      |> put_resp_header("location", conn.request_path <> "?" <> conn.query_string)
      |> put_resp_header("docker-upload-uuid", uuid)
      |> send_resp(204, "")
  end

  def patch(conn, %{"name" => name,  "uuid" => uuid, "_upload" => path} = _params) do
    locked(name)
    len = Storage.save_full_upload(path, name, uuid)
    conn
      |> put_resp_header("location", conn.request_path)
      |> put_resp_header("docker-upload-uuid", uuid)
      |> put_resp_header("range", "0-#{len}")
      |> send_resp(202, "")
  end

  @doc """
  /v2/<name>/blobs/uploads/
  开始上传 Blob 的准备
  :param request: Http 请求对象
  :param name: 镜像名
  """
  def post(_conn, %{"name" => name} = _params) when byte_size(name) > 256 do
    Logger.warn(fn -> "Image name invalid : #{name}" end)
    raise Storage.Exception,
      message: "invalid repository name",
      code: "NAME_INVALID",
      plug_status: 400,
      detail: %{}
  end

  def post(conn, %{"name" => name, "mount" => _mount} = _params) do
    locked(name)
    upload_id = Storage.create_blob(name)
    conn
    |> put_resp_header("location", conn.request_path <> upload_id)
    |> put_resp_header("docker-upload-uuid", upload_id)
    |> put_resp_header("range", "0-0")
    |> send_resp(201, "")
  end

  def post(conn, %{"name" => name} = _params) do
    locked(name)
    upload_id = Storage.create_blob(name)
    conn
    |> put_resp_header("location", conn.request_path <> upload_id)
    |> put_resp_header("docker-upload-uuid", upload_id)
    |> put_resp_header("range", "0-0")
    |> send_resp(202, "")
  end

  def delete(_conn, _params) do
    raise Storage.Exception,
     message: "The operation is unsupported",
     code: "UNSUPPORTED",
     plug_status: 405,
     detail: %{}
  end

  defp locked(name) do
    if Storage.locked?(name) do
      raise Storage.Exception,
        message: "repository readonly(LOCKED)",
        code: "REPOSITORY_LOCKED",
        plug_status: 423,
        detail: %{}
    end
  end
end
