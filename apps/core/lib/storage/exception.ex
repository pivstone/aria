defmodule Storage.Exception do
  @moduledoc """
  storage exception
  """
  defexception [:message, :code, :detail, :plug_status]
end

defimpl Core.Exception, for: Storage.Exception do
  def body(exception) do
    Poison.encode! %{"errors" => [%{"code" => exception.code,
                    "message"=> exception.message,
                    "detail" => exception.detail}]}
  end
  def status(exception), do: exception.plug_status
  def headers(_), do: %{"content_type" => "application/json"}
end
