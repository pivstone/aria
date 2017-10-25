defmodule Storage.Exception do
  @moduledoc """
  存储异常
  """
  defexception [:message, :code, :detail, :plug_status]
end

defimpl Aria.Exception, for: Storage.Exception do
  def body(exception) do
    Poison.encode! %{"errors" => [%{"code" => exception.code,
                    "message"=> exception.message,
                    "detail" => exception.detail}]}
  end
  def status(exception), do: exception.plug_status
  def headers(_), do: %{"content_type" => "application/json"}
end