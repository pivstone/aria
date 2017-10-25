defmodule Dashboard.Subscriber do
  @moduledoc"""
  注册和处理 其他模块的 signal
  """

  use GenServer
  require Logger
  alias Dashboard.Repo
  alias Phoenix.PubSub

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: Dashboard.Subscriber)
  end

  Logger.info fn ->
    :erlang.loaded
    |> Enum.map(&Atom.to_string/1)
    |> Enum.filter(fn(x) -> String.starts_with?(x, "Elixir.Dashboard") end)
  end

  def init(_) do
    Process.send_after self(), :after_init, 200
    Logger.info "Dashboard.Subscriber init ..."
    {:ok, %{}}
  end

  @doc """
  保存新建的镜像信息
  """
  def handle_info({:save_manifest, name, reference}, state) do
    Repo.insert(name, reference)
    {:noreply, state}
  end

  @doc """
  Subscriber 延迟启动的操作
  """
  def handle_info(:after_init, state) do
    PubSub.subscribe(Aria.PubSub, "manifest")
    Logger.info "Dashboard.Subscriber after init..."
    {:noreply, state}
  end
end
