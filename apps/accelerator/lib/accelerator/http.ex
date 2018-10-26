defmodule Accelerator.Http do
  @workdir "#{System.tmp_dir}/accelerator/_download"

  for x <- ~w(post put patch) do
    def unquote(:"#{x}")(url, headers, payload) do
      request(:"#{unquote x}", url, headers, payload)
    end
  end

  for x <- ~w(get delete head option) do
    def unquote(:"#{x}")(url, headers \\ []) do
      request(:"#{unquote x}", url, headers)
    end
  end

  @doc """
  Send a http request

  ## Example:

    iex> Accelerator.Http.request(:get, "https://registry-1.docker.io/v2/")
    {:ok, 401, %{"errors" => [%{"code" => "UNAUTHORIZED", "detail" => nil, "message" => "authentication required"}]}}

  """
  def request(method, url, headers \\ []) do
    method
    |> :hackney.request(url, headers, [], [{:follow_redirect, true}])
    |> response
  end

  def request(method, url, headers, payload) do
    method
    |> :hackney.request(url, headers, payload, [{:follow_redirect, true}])
    |> response
  end

  defp response({:error, reason}) do
    {:error, reason}
  end

  defp response({:ok, code, raw_headers, clientRef}) do
    headers = Enum.map(raw_headers, fn({x,y}) -> {String.downcase(x), y} end)
    parse_response({:ok, code, headers, headers, clientRef})
  end

  defp parse_response({:ok, code, [{"content-type", "application/json; charset=utf-8"}|_], raw_headers, clientRef}) do
    json(code, raw_headers, clientRef)
  end

  defp parse_response({:ok, code, [{"content-type", "application/json"}|_], raw_headers, clientRef}) do
    json(code, raw_headers, clientRef)
  end

  defp parse_response({:ok, code, [{"content-type", "application/octet-stream"}|_], raw_headers, clientRef}) do
    file(code, raw_headers, clientRef)
  end

  defp parse_response({:ok, code, [_|rest], raw_headers, clientRef}) do
    parse_response({:ok, code, rest, raw_headers, clientRef})
  end

  defp parse_response({:ok, code, _headers, raw_headers, clientRef}) do
    {:ok, body} = :hackney.body(clientRef)
    {:ok, %Response{code: code, headers: raw_headers, body: body}}
  end

  defp file(_code, _headers, clientRef) do
    tmp_file = make_random_file()
    download(clientRef, tmp_file)
  end

  defp download(ref, tmp_file) do
    case :hackney.stream_body(ref) do
      {:ok, data} ->
        File.write!(tmp_file, data, [:append, :binary])
        download(ref, tmp_file)
      :done ->
        {:ok, tmp_file}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp json(code, headers, clientRef) do
    body =
      clientRef
        |> :hackney.body
        |> elem(1)
    data = Poison.decode!(body)
    {:ok, %Response{code: code, headers: headers, data: data, body: body}}
  end

  defp make_random_file do
    path = "#{@workdir}/"
    case File.mkdir_p(path) do
       :ok ->
        path <> Random.random()
       {:error, reason} ->
        raise reason
    end
  end
 end
