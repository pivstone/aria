defmodule Accelerator.RepoTest do
  alias Accelerator.DockerUrl
  use ExUnit.Case, async: true

  setup_all %{} do
    name = "library/busybox"
    {:ok, pid} = Accelerator.Repo.start_link(name)
    %{pid: pid, name: name}
  end

  test "get tags", %{pid: pid, name: name} do
    {:ok, rsp} = GenServer.call(pid, :tags)
    assert %{"name" => ^name, "tags" => _tags} = rsp.data

  end
  test "get manifest", %{pid: pid, name: _name} do

    {:ok, rsp} = GenServer.call(pid, {:manifest, "latest"})
    assert {"docker-content-digest", "sha256:" <> _digest} = Enum.find(
             rsp.headers,
             fn (x) -> match?({"docker-content-digest", _}, x) end
           )

  end

  test "get manifest II", %{pid: pid, name: _name} do

    {:ok, %Response{code: 200} = rsp} = GenServer.call(pid, {:manifest, "latest"})
    digest = rsp.headers
             |> Enum.into(%{})
             |> Map.fetch!("docker-content-digest")
    #digest = "sha256:" <> Accelerator.Checker.hash(rsp.body)
    {:ok, rsp2} = GenServer.call(pid, {:manifest, digest})
    digest2 = rsp2.headers
                 |> Enum.into(%{})
                 |> Map.fetch!("docker-content-digest")
    assert digest == digest2

  end

  test "get blob", %{pid: pid, name: name} do

    {:ok, %Response{code: 200} = rsp} = GenServer.call(pid, {:manifest, "latest"})
    manifest = Poison.decode!(rsp.body)
    layers = Map.get(manifest, "layers") || Map.fetch!(manifest, "fsLayers")
    layer = Enum.at(layers, 0)
    digest = Map.get(layer, "digest") || Map.fetch!(layer, "blobSum")
    auth = GenServer.call(pid, :auth)
    url = DockerUrl.blobs(name, digest)
    headers = [{'Authorization', 'Bearer #{auth}'}]
    {:ok, file} = Accelerator.Http.get(url, headers)
    %{size: size} = File.stat! file
    assert size > 32
  end

  test "get blob II", %{pid: pid, name: name} do
    {:ok, %Response{code: 200} = rsp} = GenServer.call(pid, {:manifest, "latest"})
    manifest = Poison.decode!(rsp.body)
    layers = Map.get(manifest, "layers") || Map.fetch!(manifest, "fsLayers")
    layer = Enum.at(layers, 0)
    digest = Map.get(layer, "digest") || Map.fetch!(layer, "blobSum")
    auth = GenServer.call(pid, :auth)
    url = DockerUrl.blobs(name, digest)
    headers = [{'Authorization', 'Bearer #{auth}'}]
    {:ok, file} = Accelerator.Http.get(url, headers)
    %{size: size} = File.stat! file
    hash = file
           |> File.read!
           |> Accelerator.Comparator.hash
    assert "sha256:#{hash}" == digest
    assert size > 32

  end

end
