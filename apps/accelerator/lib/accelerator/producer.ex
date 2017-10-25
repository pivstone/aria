defmodule Accelerator.Producer do
  use GenStage
  require Logger

  @repo_file "config/repo.json"

  def start_link do
    GenStage.start_link(__MODULE__, [], name: Accelerator.Producer)
  end

  def init(_) do
    Logger.info fn -> "Producer starting...."  end
    if File.exists?(@repo_file) do
      list = @repo_file |> File.read! |> Poison.decode!
      {:producer, {list, 0}}
    else
      raise "config/repo.json not exists! Run mix aria.gen.images first!"
    end
  end


  def handle_demand(1, {list, position}) when position < length(list)do
    {:noreply, [name: Enum.at(list, position)], {list, position + 1}}
  end

  def handle_demand(1, {list, position}) when position == length(list)do
    {:noreply, [name: Enum.at(list, 0)], {list, 1}}
  end

end