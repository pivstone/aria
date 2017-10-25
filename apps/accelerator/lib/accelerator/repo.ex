defmodule Accelerator.Repo do
  use GenServer
  alias Accelerator.DockerUrl
  alias Accelerator.Http
  require Logger

  defstruct [:name, auth: nil]
  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def init(name) do
    send(self(), :update_auth)
    Logger.debug("Repo(#{name}) init...")
    {:ok, %__MODULE__{name: name, auth: nil}}
  end

  def handle_call(:tags, _from, state) do
    {:reply, tags(state), state}
  end

  def handle_call({:manifest, tag_name}, _from, state) do
    {:reply, manifest(state, tag_name), state}
  end

  def handle_call(:auth, _from, state) do
    {:reply, state.auth, state}
  end


  @doc """
  update auth info
  """
  def handle_info(:update_auth, state) do
    auth = auth(state.name)
    {:noreply, %__MODULE__{state|auth: auth}}
  end

  defp tags(state) do
    url = DockerUrl.tags(state.name)
    headers = [{'Authorization', 'Bearer #{state.auth}'}]
    Accelerator.Http.get(url, headers)
  end

  defp manifest(state, tag_name) do
    url = DockerUrl.manifests(state.name, tag_name)
    headers = [{'Authorization', 'Bearer #{state.auth}'}, {'Accept','application/vnd.docker.distribution.manifest.v2+json'}]
    Accelerator.Http.get(url, headers)
  end

  defp handle_auth({:ok, %Response{code: 200} = rsp}) do
    token =
      case rsp.data do
        %{"access_token" => token} ->
          token
        %{"token" => token} ->
          token
      end
    [_header, body, _] = String.split(token, ".")
    # Set a timer to refresh the auth before it expired.
    {h, s, _} = :os.timestamp
    now = h*1000_000 + s
    exp =
      body
      |> Base.url_decode64!(padding: false)
      |> Poison.decode!
      |> Map.get("exp")
    future = (exp - now) * 1000 - 3000
    Process.send_after(self(), :update_auth, future)
    token
  end

  def auth(name) do
    url = DockerUrl.upstream()

    case Accelerator.Http.get(url) do
      {:ok, %Response{code: 200}} ->
        # TODO: support not auth server
        nil
      {:ok, %Response{code: 401} = rsp} ->
        "Bearer "<> auth = rsp.headers |> Enum.into(%{}) |> Map.fetch!("www-authenticate")
        ["realm=\""<> auth_server, "service=\""<> service] = String.split(auth,",")
        auth =
          name
            |> DockerUrl.auth(auth_server, service)
            |> Http.get
            |> handle_auth
        Logger.debug fn -> "Repo(#{name}) fetch auth..." end
        auth
    end
  end
end