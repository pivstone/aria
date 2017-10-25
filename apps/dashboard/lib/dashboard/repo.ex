defmodule Dashboard.Repo do
  @moduledoc """
  Repo 的元信息
  """

  use GenServer
  require Logger
  alias Dashboard.Tag
  alias Storage.PathSpec

  @derive [Poison.Encoder]
  defstruct [
    :name,
    :namespace,
    :description,
    :source,
    :tag,
    :updated_time,
    :created_time,
    icon: "/images/imageTmp.png"]

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: Dashboard.Repo)
  end

  def init(_) do
    data_file = data_file()
    if not File.exists? (Path.dirname(data_file)) do
      :ok = data_file |> Path.dirname |> File.mkdir
    end
    {:ok, :meta} = :dets.open_file(:meta, [{:file, data_file}, {:type, :set}])
    Logger.info("Dashboard.Repo init...")
    {:ok, %{}}
  end

  def terminate(_reason, _state) do
    :dets.close(:meta)
    :ok
  end

  def new(name, [%Tag{}|_] = tags) do
    now = :os.system_time(:milli_seconds)
    %Dashboard.Repo{
      source: registry_host(),
      name: name,
      namespace: String.split(name, "/"),
      created_time: now,
      updated_time: now,
      tag: tags,
      description: registry_host() <> "/" <> name}
  end

  @doc """
  ### Example
    iex> name = "123"
    iex> refs = "latest"
    iex> repo = Dashboard.Repo.new(name, refs)
    iex> repo.name
    "123"
    iex> repo.description
    "#{Application.get_env(:dashboard, __MODULE__, [])[:registry_host]}/123"
    iex> repo.source
    "#{Application.get_env(:dashboard, __MODULE__, [])[:registry_host]}"
    iex> repo.tag
    [%Dashboard.Tag{name: "latest", updated_time: repo.updated_time}]
    iex> repo.updated_time > 0
    true
    """
  def new(name, reference) do
    now = :os.system_time(:milli_seconds)
    %Dashboard.Repo{
      source: registry_host(),
      name: name,
      namespace: String.split(name, "/"),
      created_time: now,
      updated_time: now,
      tag: [Tag.new(reference)],
      description: registry_host() <> "/" <> name}
  end

  @doc ~S"""
  ### Exmaples
    iex> Dashboard.Repo.registry_host()
    "hub.example.net"
  """
  def registry_host do
    Application.get_env(:dashboard, __MODULE__, [])[:registry_host]
  end

  @doc ~S"""
  ### Exmaples
    iex> Dashboard.Repo.insert("lib/example", "latest")
    :ok
    iex> Dashboard.Repo.list()
    ["lib/example"]
  """
  def list(mask \\ :"_") do
    for [x] <- :dets.match(:meta, {[mask, :"$1"],:"_"}), do: x
  end

  @doc ~S"""
  retrieve repo meta info via repo name
  ### Exmaples
      iex> Dashboard.Repo.insert("lib/example", "latest")
      :ok
      iex> repo = Dashboard.Repo.retrieve("lib/example")
      iex> repo.name
      "lib/example"
      iex> Dashboard.Repo.retrieve("lib/example2")
      nil
      iex> Dashboard.Repo.insert("lib/example", "onbuild")
      :ok
      iex> repo = Dashboard.Repo.retrieve("lib/example")
      iex> for tag <- repo.tag, do: tag.name
      ["onbuild", "latest"]
  """
  def retrieve(name) do
    case :dets.match(:meta, {[:"_", name], :"$1"}, 1) do
      {[[result]], _} ->
        result
      _ ->
       nil
    end
  end

  @doc ~S"""
  ### Exmaples
      iex> Dashboard.Repo.insert("lib/example", "latest")
      :ok
  """
  def insert(name, reference) do
    ns = String.split(name, "/")
    repo =
      case :dets.lookup(:meta, [ns, name]) do
        [{[_ns, _name], repo}] ->
          {tag, exists?} = update_tag(repo.tag, reference)
          tag = exists? && tag || [Tag.new(reference) | tag]

          now = :os.system_time(:milli_seconds)
          %{repo | updated_time: now, tag: tag}
        [] ->
          new(name, reference)
      end
    :dets.insert(:meta, {[ns, name], repo})
  end

  def insert_new(name, tags) when is_list(tags) do
    ns = String.split(name, "/")
    repo =
      case :dets.lookup(:meta, [ns, name]) do
        [{[_ns, _name], _repo}] ->
          :existed
        [] ->
          new(name, tags)
      end
    :dets.insert(:meta, {[ns, name], repo})
  end

  @doc ~S"""
  ### Exmaples
      iex> Dashboard.Repo.insert_new("lib/example", "latest")
      :ok
      iex> Dashboard.Repo.insert_new("lib/example", "latest")
      :existed
  """
  def insert_new(name, reference) do
    ns = String.split(name, "/")
    case :dets.lookup(:meta, [ns, name]) do
      [{[_ns, _name], _repo}] ->
        :existed
      [] ->
        repo = new(name, reference)
        :dets.insert(:meta, {[ns, name], repo})
    end
  end

  def data_file do
    System.cwd()
      |> Path.join(PathSpec.data_dir())
      |> Path.join("meta.data")
      |> String.to_charlist
  end


  defp update_tag([%Tag{name: name}|other], name, {acc, _}) do
    acc = [%Tag{updated_time: :os.system_time(:milli_seconds)}|acc]
    update_tag(other, name, {acc, true})
  end
  defp update_tag([%Tag{name: _name_} = tag|other], name, {acc,exists?}) do
    update_tag(other, name, {[tag|acc], exists?})
  end

  defp update_tag([], _name, {acc, false}), do: {acc, false}

  defp update_tag([], _name, {acc, true}), do: {acc, true}

  defp update_tag(tags, name), do: update_tag(tags, name, {[],false})
end
