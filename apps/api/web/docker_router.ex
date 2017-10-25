defmodule Api.DockerRouter do
  @moduledoc """
  Docker Router URL Regx
  Use Longest Match Rule
  """
  import Plug.Conn
  require Logger
  alias Api.ImageController
  alias Api.TagController
  alias Api.ManifestController
  alias Api.BlobController
  alias Api.BlobUploadController
  alias Api.LockController

  name_patterns =  "/v2/(?P<name>[a-z0-9]+(?:[._\/-][a-z0-9]+)*)"
  digest_patterns = "/(?P<digest>([a-z0-9]{4,6}:[a-z0-9]{32,}$))"
  reference_patterns =  "/((?P<digest>([a-z0-9]{4,6}:[a-z0-9]{32,}$))|(?P<tag>([a-z0-9][a-z0-9.-]{0,127}$)))"
  uuid_patterns =  "(?P<uuid>[a-z0-9]+(?:[._-][a-z0-9]+)*$)"
  manifest_url = Regex.compile!("^#{name_patterns}/manifests#{reference_patterns}")
  blob_url = Regex.compile!("^#{name_patterns}/blobs#{digest_patterns}")
  blob_upload_url = Regex.compile!("^#{name_patterns}/blobs/uploads/")
  blob_post_url = Regex.compile!("^#{name_patterns}/blobs/uploads/#{uuid_patterns}")
  tag_url = Regex.compile!("^#{name_patterns}/tags/list$")
  lock_url = Regex.compile!("^#{name_patterns}/_lock$")
  repo_url = Regex.compile!("^#{name_patterns}$")

  @router  %{
      tag_url => TagController,
      manifest_url => ManifestController,
      blob_url => BlobController,
      lock_url => LockController,
      blob_upload_url => BlobUploadController,
      blob_post_url => BlobUploadController,
      repo_url => ImageController,
  }


  @url_pattern  @router |> Map.keys |> Enum.sort() |> Enum.reverse

  def init(opts), do: opts

  def call(%Plug.Conn{} = conn, method) do
    try do
      for url <- @url_pattern do
        params = Regex.named_captures(url, conn.request_path)
        if params != nil do
          controller = get_in(@router, [url])
          conn = apply(controller, :call, [merge_params(conn, params), apply(controller, :init, [method])])
          throw conn
        end
      end
      conn
        |> put_resp_header("content-type", "plain/text")
        |> send_resp(404, "not_found")
        |> halt
    catch
      conn ->
       conn
    end
  end

  def merge_params(conn, params) do
    update_in conn.params, &Map.merge(&1, params)
  end
end
