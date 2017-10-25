defmodule Mix.Tasks.Aria.Gen.Images do
  use Mix.Task
  @shortdoc "Generates Offical Docker images list from index.docker.io"

  @moduledoc """
  Generates Offical Docker images from index.docker.io.
  And save the the list to `config/repo.json`
  Accelerator uses this list to pull docker image from upsteam.
  And check the specific image if updated.
  """


  @doc false
  def run(_args) do
    if File.exists?("config/repo.json") do
      IO.puts ~s"The file config/repo.json already exists!\nIf you want to rebuild, Please delete the file first."
    else
      IO.puts "Start generating the Offical Docker images list..."
      gen_repo()
      IO.puts "Finished!\The file locate in config/repo.json"
    end

  end

  defp gen_repo do
    HTTPoison.start()
    IO.puts "Fetch page(1) list..."
    data = fetch_index()
    repo =
      data
        |> Map.get("results")
        |> office_repo()
    num_pages = Map.fetch!(data, "num_pages")
    libraies =
      for page <- 2..num_pages do
        IO.puts "Fetch page(#{page}/#{num_pages}) list..."
        page
        |> fetch_index()
        |> Map.get("results")
        |> office_repo
      end
    result = List.flatten(libraies ++ repo)
    File.write!("config/repo.json", Poison.encode!(result, pretty: true))
  end

  defp office_repo(data) do
    data
    |> Enum.filter(fn(x) ->
      Map.get(x,"is_official", false)
     end)
    |> Enum.map(fn (x)->
      "library/"<> Map.fetch!(x, "name")
      end)
  end

  defp fetch_index(page \\ 1) do
    url = "https://index.docker.io/v1/search?q=library&n=100&page=#{page}"
    headers = [{'X-Docker-Token','True'}]
    {:ok, rsp} = Accelerator.Http.get(url, headers)
    rsp.data
  end
end