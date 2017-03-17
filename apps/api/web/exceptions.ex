defimpl Plug.Exception, for: Storage.Exceptions.NotFoundError do
  def status(_exception), do: 404
end


defmodule Api.DockerError do
  defexception [:message , :code, :detail ,:plug_status]
end