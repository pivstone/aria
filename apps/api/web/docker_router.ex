defmodule Api.DockerRouter do
  import Plug.Conn

  def init(opts), do: opts

  @name_patterns "/(?P<name>[a-z0-9]+(?:[._\/-][a-z0-9]+)*)"
  @reference_patterns "/((?P<digest>([a-z0-9]{4,6}:[a-z0-9]{32,}$))|(?P<tag>([a-z0-9][a-z0-9.-]{0,127}$)))"
  @manifest_url Regex.compile!("^/v2#{@name_patterns}/manifests#{@reference_patterns}")
  @uuid_patterns "(?P<uuid>[a-z0-9]+(?:[._-][a-z0-9]+)*$)"
  @blob_url Regex.compile!("^/v2#{@name_patterns}/blobs/#{@uuid_patterns}")
  @tag_url Regex.compile!("^/v2#{@name_patterns}/tags/list")
  @doc """
  CN: Docker 的路由跳转
  """

  def call(%Plug.Conn{} = conn, :get) do
    cond do
      (params = Regex.named_captures(@tag_url, conn.request_path)) != nil ->
        conn
        |> merge_params(params)
        |> Api.ImageController.call(Api.ImageController.init(:tag_list))
      (params = Regex.named_captures(@manifest_url, conn.request_path)) != nil ->
        conn
        |> merge_params(params)
        |> Api.ManifestController.call(Api.ManifestController.init(:show))
      true ->
        conn
        |> send_resp(404,"not_found")
        |> halt
    end
  end

  def call(%Plug.Conn{} = conn, :post) do
    cond do
      String.ends_with?(conn.request_path,"/blobs/uploads/") ->
        "/v2/" <> name = conn.request_path
        name = name |> String.slice(0..-16)
        conn = merge_params(conn,%{"name" => name})
        Api.ImageController.call(conn, Api.BlobController.init(:init_upload))
      true ->
        conn
        |> send_resp(404,"not_found")
        |> halt
    end
  end

  def call(%Plug.Conn{} = conn, :head) do
    cond do
      true -> conn
    end
  end

  def call(%Plug.Conn{} = conn, :put) do
    cond do
      (params = Regex.named_captures(@manifest_url, conn.request_path)) != nil ->
        conn
        |> merge_params(params)
        |> Api.ManifestController.call(Api.ManifestController.init(:save))
      (params = Regex.named_captures(@blob_url, conn.request_path)) != nil ->
        conn
        |> merge_params(params)
        |> Api.BlobController.call(Api.BlobController.init(:upload))
      true ->
        conn
        |> send_resp(404,"not_found")
        |> halt
    end
  end

  def call(%Plug.Conn{} = conn, :delete) do
    cond do
      true ->
        conn
        |> send_resp(404,"not_found")
        |> halt
    end
  end

  def merge_params(conn,params) do
    update_in conn.params ,&Map.merge(&1,params)
  end
end
