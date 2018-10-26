defmodule Accelerator.DockerUrl do

  @default_upstream "https://hub.c.163.com/v2/"

  def upstream do
    Application.get_env(:accelerator, __MODULE__, [])[:upstream] || @default_upstream
  end

  def auth(name, server, serivce) do
    server = String.trim(server, "\"")
    serivce = String.trim(serivce, "\"")
    "#{server}?scope=#{URI.encode_www_form("repository:#{name}:pull")}&service=#{URI.encode_www_form serivce}"
  end

  def tags(name) do
     URI.encode("#{upstream()}#{name}/tags/list")
  end

  def manifests(name, tag) do
     URI.encode("#{upstream()}#{name}/manifests/#{tag}")
  end

  def blobs(name, digest) do
     URI.encode("#{upstream()}#{name}/blobs/#{digest}")
  end

end
