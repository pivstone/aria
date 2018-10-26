defmodule Accelerator.Comparator do
  use GenStage
  alias Phoenix.PubSub
  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, [], name: Accelerator.Comparator)
  end

  def init(_) do
    cache = :ets.new(:repo, [])
    {:producer_consumer, cache, subscribe_to: [{Accelerator.Producer, max_demand: 1}]}
  end

  def handle_events([name: name], _from, cache) do
    Logger.debug fn -> "Checker received #{name}" end
    {:ok, repo} = Accelerator.Repo.start_link(name)
    check_storage(name, cache)
    case GenServer.call(repo, :tags, 30_000) do
      {:ok, %Response{code: 200} = rsp} ->
        tags = Map.fetch!(rsp.data, "tags")
        Logger.info fn -> "#{name} tags: #{inspect tags}" end
        if tags == nil do
          Logger.warn fn -> "Fetching #{name}'s tags failed#{inspect rsp}" end
        end
        data =
          for tag <- tags || [] do
            {:ok, rsp} = GenServer.call(repo, {:manifest, tag}, 30_000)
            digest = hash(rsp.body)
            case :ets.lookup(cache, [name, tag]) do
              [{[^name, ^tag], ^digest}] ->
                nil # not update
              [{[^name, ^tag], new_digest}] ->
                :ets.insert(cache, {[name, tag], new_digest})
                Logger.info fn -> "#{name}'s tag:#{tag} need update" end
                PubSub.broadcast_from! Aria.PubSub, self(), "accelerator", {:tag_update, new_digest, tag, name}
                {new_digest, tag, name}
              [] ->
                :ets.insert(cache, {[name, tag], digest})
                Logger.info fn -> "#{name} new tag:#{tag} found" end
                PubSub.broadcast_from! Aria.PubSub, self(), "accelerator", {:new_tag, digest, tag, name}
                {digest, tag, name}
            end
          end
        GenServer.stop(repo, :normal)
        {:noreply, Enum.filter(data, &(&1)), cache}
      {:ok, %Response{code: 404}} ->
        Logger.error fn -> "Repo(#{name}): not found!" end
        GenServer.stop(repo, :normal)
        {:noreply, [], cache}
      {:ok, %Response{code: 401}} ->
        Logger.error fn -> "Repo(#{name}): auth failed!" end
        {:noreply, [], cache}
    end
  end

  def check_storage(name, pid) do
    for tag <- Storage.tags(name) do
      manifest = Storage.manifest(name, tag)
      digest = hash(manifest)
      :ets.insert(pid, {[name, tag], digest})
    end
  rescue
    Storage.Exception ->
      nil # Nothing can do
  end

  def hash(data) do
    :sha256
    |> :crypto.hash_init
    |> :crypto.hash_update(data)
    |> :crypto.hash_final
    |> Base.encode16(case: :lower)
  end
end
