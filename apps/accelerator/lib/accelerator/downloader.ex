defmodule Accelerator.Downloader do
  use GenStage
  alias Accelerator.DockerUrl
  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, [])
  end

  def init(_) do
    Logger.info fn -> "Downloader starting...."  end
    {:consumer, [], subscribe_to: [{Accelerator.Comparator, max_demand: 1}]}
  end

  def handle_events([{_digest, tag, name}], _from, state) do
    {:ok, repo} = Accelerator.Repo.start_link(name)
    {:ok, rsp} = GenServer.call(repo, {:manifest, tag})
    auth = GenServer.call(repo, :auth)
    manifest = Poison.decode!(rsp.body)
    config_digest = get_in manifest, ["config", "digest"]
    if config_digest != nil do
      download(config_digest, name, auth)
    end
    for layer <- Map.get(manifest, "layers")|| Map.fetch!(manifest, "fsLayers") do
      digest = Map.get(layer, "digest") || Map.fetch!(layer, "blobSum")
      auth = GenServer.call(repo, :auth)
      download(digest, name, auth)
    end
    Manifest.save(rsp.body, name, tag)
    {:noreply, [], state}
  end

  defp save_blob(file_name, name, digest) do
    target_name = Storage.PathSpec.blob_path(name, digest)
    Storage.driver().move(file_name, target_name)
  end

  defp download(digest, name, auth) do
    Logger.info fn -> "start download #{name}/#{digest}" end
    if Storage.exists?(name, digest) do
      {:already_exists, digest}
    else
      url = DockerUrl.blobs(name, digest)
      headers = [{'Authorization', 'Bearer #{auth}'}]
      case Accelerator.Http.get(url, headers) do
        {:ok, file_name} ->
          Logger.debug "tmp file:#{file_name}"
          save_blob(file_name, name, digest)
      end
    Logger.info fn -> "Download completed #{name}/#{digest}" end
    end
  end
end