defmodule Api.ManifestController do
	use Api.Web, :controller

  @scheme1 "application/vnd.docker.distribution.manifest.v1+prettyjws"
  @scheme2 "application/vnd.docker.distribution.manifest.v2+json"


  @doc """
  返回指定 Image 的 Manifest
  """
  def get(conn, %{"name" => name, "tag" => tag} = params) do
    render conn, "index.json",data: params
  end

  @doc """
  返回指定 Image 的 Manifest
  """
  def get(conn, %{"name" => name, "digest" => digest} = _params) do
    content = Storage.get_manifest(name, digest)
    accept_list = conn.accepts
    schema_v2 =
      if Enum.member?(@scheme1,accept_list) and not Enum.member?(@scheme2,accept_list) do
         false
      else
        true
      end
    manifest = Poison.decode!(content)
    # 本地存储的 manifest version
    manifest_version = not Map.has_key?(manifest,"mediaType") && 1 || 2

    if not schema_v2 and manifest_version != 1 do
       # TODO v2 -> v1
    end
    if schema_v2 and manifest_version == 1 do
      raise Api.DockerError,
            message: "manifest unsupported",
            code: "MANIFEST UNSUPPORTED",
            plug_status: 415,
            detail: %{}
    end
    conn
    |> put_req_header("content-Type",@scheme2)
    |> send_resp(:ok,content)
  end

  @doc """
  保存 Manifest
  """
  def put(conn,params) do
    render conn, "index.json",data: params
  end

  @doc """
  删除 Manifest
  """
  def delete(conn,params) do
    render conn, "index.json",data: params
  end

end