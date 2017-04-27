defmodule Api.ManifestController do
	use Api.Web, :controller

  @scheme1 "application/vnd.docker.distribution.manifest.v1+prettyjws"
  @scheme2 "application/vnd.docker.distribution.manifest.v2+json"

  @doc """
  返回指定 Image 的 Manifest
  """
  def get(conn, %{"name" => name, "digest" => digest ,"tag" => tag} = _params) do
    refs = digest != "" && digest || tag
    content = Storage.get_manifest(name, refs)
    accept_list = get_req_header(conn, "accept")
    schema_v2 =
      if Enum.member?(accept_list, @scheme2) and not Enum.member?(accept_list, @scheme1) do
        true
      else
        false
      end
    manifest = Poison.decode!(content)
    # 本地存储的 manifest version
    manifest_version = not Map.has_key?(manifest,"mediaType") && 1 || 2
    content =
      if not schema_v2 and manifest_version != 1 do
         Manifest.transform_v2_to_v1(content,name,refs)
      else
        content
      end
    if schema_v2 and manifest_version == 1 do
      raise Docker.Exception,
            message: "manifest unsupported",
            code: "MANIFEST UNSUPPORTED",
            plug_status: 415,
            detail: %{}
    end
    conn
    |> put_resp_header("content-type",@scheme2)
    |> send_resp(:ok,content)
  end



  @doc """
  返回指定 Image 的 Manifest
  """
  def get(conn, params) do
    render conn, "index.json",data: params
  end

  @doc """
  保存 Manifest
  """
  def put(conn,%{"name" => name, "digest" => _digest, "tag" => tag, "data" => data} = _params) do
    [schema] = get_req_header(conn, "content-type")
    if schema == nil  do
      raise Docker.Exception,
              message: "Manifest Invalid",
              code: "MANIFEST_INVALID",
              plug_status: 400
    end
    if not schema in [@scheme1, @scheme2] do
      raise Docker.Exception,
              message: "The operation is unsupported",
              code: "UNSUPPORTED",
              plug_status: 405
    end
    # TODO: check digest
    Manifest.save(data, name, tag)
    render conn, "index.json",data: %{"name"=>name,"reference"=>tag}
  end

  @doc """
  删除 Manifest
  """
  def delete(conn,params) do
    render conn, "index.json",data: params
  end

end