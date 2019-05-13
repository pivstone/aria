defmodule Dashboard.Checker do
  @moduledoc"""
  Verify image meta data in schdule, repair meta data if fault is found
  """
  use GenServer
  require Logger
  alias Dashboard.Repo
  alias Dashboard.Tag

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: Dashboard.Checker)
  end

  def init(_) do
    Process.send_after self(), :work, 100
    Logger.info(fn -> "Dashboard.Checker init.."  end)
    {:ok, %{}}
  end

  def handle_info(:work, state) do
    Logger.info(fn -> "Dashboard.Checker start working.."  end)
    for name <- Storage.repositories("") do
      spawn(fn -> check_repo(name) end)
    end
    Process.send_after self(), :work, 1000 * 60 * 3
    {:noreply, state}
  end

  defp check_repo(name) do
    repo = Repo.retrieve(name)
    tag_list = Storage.tags(name)
    if repo == nil do
      Logger.info(fn -> "Dashboard.Checker fix repo:#{name}..."  end)
      tags =
        for tag <- tag_list do
          Tag.new(tag)
        end
      Repo.insert_new(name, tags)
    else
      nil
    end
  end
end
