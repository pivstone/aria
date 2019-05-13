defprotocol Core.Exception do

  @moduledoc """
  Exception handler
  """

  @fallback_to_any true
  @doc """
  Exception page rendered body

  ### Example
    def status(NotAuthenticatedException), do: %{"msg" => "unauthriozed"}

  """
  def body(exception)

  @fallback_to_any true
  @doc """
  Exception http status code & header

  ### Example

    def status(NotAuthenticatedException), do: %{"location" => "http://127.0.0.1"}

    iex> Aria.Exception.status(%ArgumentError{message: "argument error"})
    500
  """
  def headers(exception)

  @fallback_to_any true
  @doc """
  Exception status code

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
