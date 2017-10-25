defmodule Api.ManifestController do
  use Api.Web, :controller

  @scheme1 "application/vnd.docker.distribution.manifest.v1+prettyjws"
  @scheme2 "application/vnd.docker.distribution.manifest.v2+json"

  @doc """
  返回指定 Image 的 Manifest
  """
  def get(conn, %{"name" => name, "digest" => digest, "tag" => tag} = _params) do
    refs = digest != "" && digest || tag
    content = Storage.get_manifest(name, refs)
    accept_list = get_req_header(conn, "accept")
    schema_v1 = Enum.member?(accept_list, @scheme1)
    manifest = Poison.decode!(content)
    # 本地存储的 manifest version
    manifest_version = Map.has_key?(manifest, "mediaType") && 2 || 1
    type = @scheme2
    content =
      if schema_v1 and manifest_version != 1 do
        manifest |> Manifest.transform_v2_to_v1(name, refs) |> Poison.encode!(pretty: true)
      else
        content
      end
    type =
    if manifest_version == 1 do
      @scheme1
    else
      @scheme2
    end
    conn
      |> put_resp_header("content-type", type)
      |> send_resp(:ok, content)
  end


  @doc """
  返回指定 Image 的 Manifest
  """
  def get(conn, params) do
    render conn, "index.json", data: params
  end

  @doc """
  保存 Manifest
  """
  def put(conn, %{"name" => name, "digest" => _digest, "tag" => tag, "data" => data} = _params) do
    if Storage.locked?(name) do
      raise Storage.Exception,
        message: "repository readonly(LOCKED)",
        code: "REPOSITORY_LOCKED",
        plug_status: 423,
        detail: %{}
    end
    [schema] = get_req_header(conn, "content-type")
    if schema == nil do
      raise Storage.Exception,
        message: "Manifest Invalid",
        code: "MANIFEST_INVALID",
        plug_status: 400
    end
    if not schema in [@scheme1, @scheme2] do
      raise Storage.Exception,
        message: "The operation is unsupported",
        code: "UNSUPPORTED",
        plug_status: 405
    end
    if Manifest.verify(name, data) do
      Manifest.save(data, name, tag)
      render conn, "index.json", data: %{"name" => name, "reference" => tag}
    else
      raise Storage.Exception,
        message: "Manifest Invalid",
        code: "MANIFEST_INVALID",
        plug_status: 400
    end
  end

  @doc """
  删除 Manifest
  """
  def delete(conn, %{"name" => name, "digest" => "", "tag" => tag}) do
    case Storage.untag(name, tag) do
      {:ok, _} ->
        send_resp(conn, :no_content, "")
      {:error, reason} ->
        raise reason
    end
  end


  @doc """
  删除 Manifest
  """
  def delete(_conn, _param) do
    raise Storage.Exception,
      message: "operation is not supported yet.",
      code: "OPTS_NOT_SUPPORTED",
      plug_status: 405
  end
end
