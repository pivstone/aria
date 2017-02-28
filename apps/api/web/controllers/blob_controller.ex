defmodule Api.BlobController do
	use Api.Web, :controller

  def get(conn, _params) do
    render conn, "index.json",tag: []
  end

  def put(conn, _params) do
    render conn, "index.json",tag: []
  end

  def head(conn, _params) do
    render conn, "index.json",tag: []
  end

  def patch(conn, _params) do
    render conn, "index.json",tag: []
  end

  def post(conn, _params) do
    render conn, "index.json",tag: []
  end

  @doc """
  /v2/<name>/blobs/uploads/
  开始上传 Blob 的准备
  :param request: Http 请求对象
  :param name: 镜像名
  """
  def init_upload(conn, %{"name" => name} = _params) when byte_size(name) > 256 do
     raise :NameInvalidException
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