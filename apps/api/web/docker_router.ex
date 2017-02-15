defmodule Api.DockerRouter do
  def init(opts), do: opts


  @name_patterns "(?P<name>[a-z0-9]+(?:[._\/-][a-z0-9]+)*)"
  @reference_patterns "/((?P<digest>([a-z0-9]{4,6}:[a-z0-9]{32,}$))|(?P<tag>([a-z0-9][a-z0-9.-]{0,127}$)))"
  @manifest_url Regex.compile!("/v2/#{@name_patterns}/manifest#{@reference_patterns}")

  def call(%Plug.Conn{} = conn, :get) do
    cond do
      String.ends_with?(conn.request_path,"/tags/list") ->
        "/v2/" <> name = conn.request_path
        name = name |> String.slice(0..-11)
        conn = merge_params(conn,%{"name" => name})
        Api.ImageController.call(conn, Api.ImageController.init(:tag_list))
      %{} = params = Regex.named_captures(@manifest_url, conn.request_path) ->
        conn
        |> merge_params(params)
        |> Api.ManifestController.call(Api.ManifestController.init(:show))
      true -> conn
    end
  end

  def call(%Plug.Conn{} = conn, :post) do
    cond do
      String.ends_with?(conn.request_path,"/blobs/uploads/") ->
        "/v2/" <> name = conn.request_path
        name = name |> String.slice(0..-16)
        conn = merge_params(conn,%{"name" => name})
        Api.ImageController.call(conn, Api.BlobController.init(:init_upload))

      true -> conn
    end
  end

  def merge_params(conn,params) do
    update_in conn.params ,&Map.merge(&1,params)
  end
end
