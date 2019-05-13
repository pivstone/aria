defmodule Dashboard.Subscriber do
  @moduledoc"""
  Register and handle module signals
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
  Save new image meta data
  """
  def handle_info({:save_manifest, name, reference}, state) do
    Repo.insert(name, reference)
    {:noreply, state}
  end

  @doc """
  Subscribe topic after init
  """
  def handle_info(:after_init, state) do
    PubSub.subscribe(Aria.PubSub, "manifest")
    Logger.info "Dashboard.Subscriber after init..."
    {:noreply, state}
  end
end
