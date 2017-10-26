defprotocol Core.Exception do

  @moduledoc """
  异常处理 handler
  """

  @fallback_to_any true
  @doc """
  渲染异常显示的 body

  ### Example
    def status(NotAuthenticatedException), do: %{"msg" => "unauthriozed"}

  """
  def body(exception)

  @fallback_to_any true
  @doc """
  准备异常返回的 headers (例如 BasicAuth 的 301 等)

  ### Example

    def status(NotAuthenticatedException), do: %{"location" => "http://127.0.0.1"}

    iex> Aria.Exception.status(%ArgumentError{message: "argument error"})
    500
  """
  def headers(exception)

  @fallback_to_any true
  @doc """
  异常的状态码

  ### Example

    def status(NotAuthenticatedException), do: 401
  """
  def status(exception)
end


defimpl Core.Exception, for: Any do
  require Logger

  def body(exception) do
    Logger.error(Exception.format(:error, exception))
    if Logger.level == :debug do
      Exception.message(exception)
    else
      "server internal error"
    end
  end
  def headers(_), do: %{}
  def status(_), do: 500
end


defimpl Core.Exception, for: Atom do
  require Logger
  def body(exception) do
    messgae = ~s/#{exception}/
    if Logger.level == :debug do
      messgae
    else
      "server internal error"
    end
  end
  def headers(_), do: %{}
  def status(_), do: 500
end